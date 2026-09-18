from fastapi import (
    FastAPI,
    HTTPException,
    UploadFile,
    File,
    Form,
)
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from PIL import (
    Image,
    ImageEnhance,
    ImageOps,
    ImageFilter,
)
from io import BytesIO
import base64
import os
import hmac
import hashlib
import uvicorn
import razorpay

from dotenv import load_dotenv


# ============================================================
# RAZORPAY CONFIGURATION
# ============================================================

load_dotenv()

RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID")
RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET")

if not RAZORPAY_KEY_ID or not RAZORPAY_KEY_SECRET:
    print("WARNING: Razorpay credentials are not configured.")
    razorpay_client = None
else:
    razorpay_client = razorpay.Client(
        auth=(RAZORPAY_KEY_ID, RAZORPAY_KEY_SECRET)
    )


# ============================================================
# HERITRACE AI BACKEND
# ============================================================

app = FastAPI(
    title="HeriTrace AI Backend",
    version="1.0.0",
)


# ============================================================
# CORS
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# REQUEST MODELS
# ============================================================

class CatalogRequest(BaseModel):
    name: str
    category: str = "Handicraft"
    language: str = "English"
    notes: str = ""


class PricingRequest(BaseModel):
    product_name: str
    category: str = "Handicraft"
    cost_price: float = 0
    quality: str = "standard"
    demand: str = "normal"


class ImageEnhanceRequest(BaseModel):
    image_base64: str
    product_name: str = "HeriTrace Product"


class SpeechRequest(BaseModel):
    text: str
    language: str = "English"


class RazorpayCreateOrderRequest(BaseModel):
    amount: float
    receipt: str = "heritrace_order"
    notes: dict = {}


class RazorpayVerifyRequest(BaseModel):
    razorpay_order_id: str
    razorpay_payment_id: str
    razorpay_signature: str


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def root():
    return {
        "success": True,
        "message": "HeriTrace AI Backend is running",
        "version": "1.0.0",
    }


# ============================================================
# HEALTH
# ============================================================

@app.get("/health")
def health():
    return {
        "status": "ok",
        "service": "HeriTrace AI Backend",
    }



# ============================================================
# RAZORPAY PAYMENTS
# ============================================================

@app.post("/payments/create-order")
def create_razorpay_order(request: RazorpayCreateOrderRequest):
    """Create a Razorpay order. Amount is supplied in rupees and sent to Razorpay in paise."""
    if razorpay_client is None:
        raise HTTPException(status_code=500, detail="Razorpay is not configured on the server.")

    try:
        amount_rupees = float(request.amount)
        if amount_rupees <= 0:
            raise HTTPException(status_code=400, detail="Payment amount must be greater than zero.")

        amount_paise = int(round(amount_rupees * 100))
        order_data = {
            "amount": amount_paise,
            "currency": "INR",
            "receipt": request.receipt[:40],
            "payment_capture": 1,
        }
        if request.notes:
            order_data["notes"] = request.notes

        razorpay_order = razorpay_client.order.create(data=order_data)
        return {
            "success": True,
            "key_id": RAZORPAY_KEY_ID,
            "order_id": razorpay_order["id"],
            "amount": razorpay_order["amount"],
            "currency": razorpay_order["currency"],
            "receipt": razorpay_order["receipt"],
        }
    except HTTPException:
        raise
    except Exception as e:
        print("RAZORPAY CREATE ORDER ERROR:", e)
        raise HTTPException(status_code=500, detail=f"Unable to create Razorpay order: {str(e)}")


@app.post("/payments/verify")
def verify_razorpay_payment(request: RazorpayVerifyRequest):
    """Verify the Razorpay payment signature on the server."""
    if razorpay_client is None:
        raise HTTPException(status_code=500, detail="Razorpay is not configured on the server.")

    try:
        generated_signature = hmac.new(
            RAZORPAY_KEY_SECRET.encode("utf-8"),
            (request.razorpay_order_id + "|" + request.razorpay_payment_id).encode("utf-8"),
            hashlib.sha256,
        ).hexdigest()

        if not hmac.compare_digest(generated_signature, request.razorpay_signature):
            raise HTTPException(status_code=400, detail="Payment signature verification failed.")

        razorpay_client.utility.verify_payment_signature({
            "razorpay_order_id": request.razorpay_order_id,
            "razorpay_payment_id": request.razorpay_payment_id,
            "razorpay_signature": request.razorpay_signature,
        })

        return {
            "success": True,
            "verified": True,
            "payment_id": request.razorpay_payment_id,
            "order_id": request.razorpay_order_id,
            "message": "Payment verified successfully.",
        }
    except HTTPException:
        raise
    except Exception as e:
        print("RAZORPAY VERIFY ERROR:", e)
        raise HTTPException(status_code=400, detail="Payment verification failed.")


@app.get("/payments/config")
def razorpay_config():
    """Return the public Razorpay Key ID only. Never return the Key Secret."""
    if not RAZORPAY_KEY_ID:
        return {"success": False, "configured": False}
    return {"success": True, "configured": True, "key_id": RAZORPAY_KEY_ID}

# ============================================================
# AI CATALOG GENERATOR
# ============================================================

@app.post("/ai/generate-catalog")
def generate_catalog(
    request: CatalogRequest,
):

    name = request.name.strip()
    category = (
        request.category.strip()
        or "Handicraft"
    )
    language = (
        request.language.strip().lower()
    )
    notes = request.notes.strip()

    if not name:
        raise HTTPException(
            status_code=400,
            detail="Product name is required.",
        )

    # --------------------------------------------------------
    # ENGLISH
    # --------------------------------------------------------

    if language == "english":

        title = f"Handcrafted {name}"

        description = (
            f"Discover the beauty of our "
            f"handcrafted {name}. Made with "
            f"traditional craftsmanship and "
            f"attention to detail, this "
            f"{category.lower()} product brings "
            f"authentic heritage and artistic "
            f"character to your home or collection."
        )

        if notes:
            description += f" {notes}"

        keywords = [
            "handmade",
            "handcrafted",
            "traditional craft",
            "Indian handicraft",
            category.lower(),
            name.lower(),
        ]

    # --------------------------------------------------------
    # HINDI
    # --------------------------------------------------------

    elif language == "hindi":

        title = f"à¤¹à¤¸à¥à¤¤à¤¨à¤¿à¤°à¥à¤®à¤¿à¤¤ {name}"

        description = (
            f"à¤¹à¤®à¤¾à¤°à¥‡ à¤¹à¤¸à¥à¤¤à¤¨à¤¿à¤°à¥à¤®à¤¿à¤¤ {name} à¤•à¥€ "
            f"à¤¸à¥à¤‚à¤¦à¤°à¤¤à¤¾ à¤”à¤° à¤ªà¤¾à¤°à¤‚à¤ªà¤°à¤¿à¤• à¤•à¤¾à¤°à¥€à¤—à¤°à¥€ à¤•à¤¾ "
            f"à¤…à¤¨à¥à¤à¤µ à¤•à¤°à¥‡à¤‚à¥¤ à¤¯à¤¹ {category} à¤‰à¤¤à¥à¤ªà¤¾à¤¦ "
            f"à¤•à¥à¤¶à¤² à¤•à¤¾à¤°à¥€à¤—à¤°à¥‹à¤‚ à¤¦à¥à¤µà¤¾à¤°à¤¾ à¤¸à¤¾à¤µà¤§à¤¾à¤¨à¥€ à¤”à¤° "
            f"à¤ªà¤°à¤‚à¤ªà¤°à¤¾ à¤•à¥‡ à¤¸à¤¾à¤¥ à¤¤à¥ˆà¤¯à¤¾à¤° à¤•à¤¿à¤¯à¤¾ à¤—à¤¯à¤¾ à¤¹à¥ˆà¥¤"
        )

        if notes:
            description += f" {notes}"

        keywords = [
            "à¤¹à¤¸à¥à¤¤à¤¨à¤¿à¤°à¥à¤®à¤¿à¤¤",
            "à¤¹à¤¸à¥à¤¤à¤¶à¤¿à¤²à¥à¤ª",
            "à¤ªà¤¾à¤°à¤‚à¤ªà¤°à¤¿à¤• à¤•à¤²à¤¾",
            "à¤à¤¾à¤°à¤¤à¥€à¤¯ à¤¹à¤¸à¥à¤¤à¤¶à¤¿à¤²à¥à¤ª",
            category,
            name,
        ]

    # --------------------------------------------------------
    # ODIA
    # --------------------------------------------------------

    elif language == "odia":

        title = f"à¬¹à¬¸àà¬¤à¬¨à¬¿à¬°àà¬®à¬¿à¬¤ {name}"

        description = (
            f"à¬†à¬®à¬° à¬¹à¬¸àà¬¤à¬¨à¬¿à¬°àà¬®à¬¿à¬¤ {name} à¬° "
            f"à¬¸àà¬¨àà¬¦à¬°à¬¤à¬¾ à¬à¬¬à¬‚ à¬ªà¬¾à¬°à¬®àà¬ªà¬°à¬¿à¬• "
            f"à¬•à¬¾à¬°à¬¿à¬—à¬°à€à¬•à à¬…à¬¨àà¬à¬¬ à¬•à¬°à¬¨àà¬¤àà¥¤ "
            f"à¬à¬¹à¬¿ {category} à¬‰à¬¤àà¬ªà¬¾à¬¦à¬Ÿà¬¿ à¬¦à¬•àà¬· "
            f"à¬•à¬¾à¬°à¬¿à¬—à¬°à¬®à¬¾à¬¨à¬™àà¬• à¬¦àà±à¬¾à¬°à¬¾ à¬ªà¬°à¬®àà¬ªà¬°à¬¾ "
            f"à¬à¬¬à¬‚ à¬¯à¬¤àà¬¨ à¬¸à¬¹à¬¿à¬¤ à¬ªàà¬°à¬¸àà¬¤àà¬¤à¥¤"
        )

        if notes:
            description += f" {notes}"

        keywords = [
            "à¬¹à¬¸àà¬¤à¬¨à¬¿à¬°àà¬®à¬¿à¬¤",
            "à¬¹à¬¸àà¬¤à¬¶à¬¿à¬³àà¬ª",
            "à¬ªà¬¾à¬°à¬®àà¬ªà¬°à¬¿à¬• à¬•à¬³à¬¾",
            "à¬à¬¾à¬°à¬¤à€àŸ à¬¹à¬¸àà¬¤à¬¶à¬¿à¬³àà¬ª",
            category,
            name,
        ]

    # --------------------------------------------------------
    # BENGALI
    # --------------------------------------------------------

    elif language == "bengali":

        title = f"à¦¹à¦¸à§à¦¤à¦¨à¦¿à¦°à§à¦®à¦¿à¦¤ {name}"

        description = (
            f"à¦†à¦®à¦¾à¦¦à§‡à¦° à¦¹à¦¸à§à¦¤à¦¨à¦¿à¦°à§à¦®à¦¿à¦¤ {name}-à¦à¦° "
            f"à¦¸à§Œà¦¨à§à¦¦à¦°à§à¦¯ à¦à¦¬à¦‚ à¦¦¤à¦¿à¦¹à§à¦¯à¦¬à¦¾à¦¹à§€ à¦•à¦¾à¦°à§à¦¶à¦¿à¦²à§à¦ªà§‡à¦° "
            f"à¦…à¦à¦¿à¦œà§à¦žà¦¤à¦¾ à¦¨à¦¿à¦¨à¥¤ à¦à¦‡ {category} à¦ªà¦£à§à¦¯à¦Ÿà¦¿ "
            f"à¦¦à¦•à§à¦· à¦•à¦¾à¦°à¦¿à¦—à¦°à¦¦à§‡à¦° à¦¦à§à¦¬à¦¾à¦°à¦¾ à¦¯à¦¤à§à¦¨ à¦à¦¬à¦‚ "
            f"à¦¦¤à¦¿à¦¹à§à¦¯à§‡à¦° à¦¸à¦™à§à¦—à§‡ à¦¤à§ˆà¦°à¦¿ à¦•à¦°à¦¾ à¦¹à¦¯à¦¼à§‡à¦›à§‡à¥¤"
        )

        if notes:
            description += f" {notes}"

        keywords = [
            "à¦¹à¦¸à§à¦¤à¦¨à¦¿à¦°à§à¦®à¦¿à¦¤",
            "à¦¹à¦¸à§à¦¤à¦¶à¦¿à¦²à§à¦ª",
            "à¦¦¤à¦¿à¦¹à§à¦¯à¦¬à¦¾à¦¹à§€ à¦¶à¦¿à¦²à§à¦ª",
            "à¦à¦¾à¦°à¦¤à§€à¦¯à¦¼ à¦¹à¦¸à§à¦¤à¦¶à¦¿à¦²à§à¦ª",
            category,
            name,
        ]

    # --------------------------------------------------------
    # FALLBACK
    # --------------------------------------------------------

    else:

        title = f"Handcrafted {name}"

        description = (
            f"A beautifully handcrafted "
            f"{name}, created with traditional "
            f"craftsmanship."
        )

        keywords = [
            "handmade",
            "handcrafted",
            category.lower(),
            name.lower(),
        ]

    return {
        "success": True,
        "title": title,
        "description": description,
        "category": category,
        "keywords": keywords,
        "language": request.language,
    }


# ============================================================
# AI DYNAMIC PRICING
# ============================================================

@app.post("/ai/recommend-price")
def recommend_price(
    request: PricingRequest,
):

    cost = max(
        float(request.cost_price),
        0,
    )

    quality_multiplier = {
        "basic": 1.10,
        "standard": 1.35,
        "high": 1.60,
        "premium": 1.90,
    }

    demand_multiplier = {
        "low": 0.90,
        "normal": 1.00,
        "high": 1.20,
    }

    q_multiplier = quality_multiplier.get(
        request.quality.lower(),
        1.35,
    )

    d_multiplier = demand_multiplier.get(
        request.demand.lower(),
        1.00,
    )

    if cost <= 0:

        base_price = {
            "handicraft": 900,
            "textile": 1400,
            "pottery": 850,
            "jewellery": 1800,
            "basket": 700,
            "woodcraft": 1200,
        }.get(
            request.category.lower(),
            1000,
        )

    else:

        base_price = cost * 1.45

    recommended = (
        base_price
        * q_multiplier
        * d_multiplier
    )

    recommended = (
        round(recommended / 50) * 50
    )

    minimum_price = max(
        cost * 1.15,
        recommended * 0.82,
    )

    premium_price = (
        recommended * 1.20
    )

    profit = (
        recommended - cost
    )

    if recommended > 0:

        margin = (
            profit / recommended
        ) * 100

    else:

        margin = 0

    return {
        "success": True,
        "product_name":
            request.product_name,
        "category":
            request.category,
        "cost_price":
            round(cost, 2),
        "recommended_price":
            round(recommended, 2),
        "minimum_price":
            round(minimum_price, 2),
        "premium_price":
            round(premium_price, 2),
        "estimated_profit":
            round(profit, 2),
        "estimated_margin":
            round(margin, 2),
        "quality":
            request.quality,
        "demand":
            request.demand,
        "explanation":
            (
                "The recommended price considers "
                "production cost, product quality, "
                "and current demand level."
            ),
    }


# ============================================================
# IMAGE ENHANCEMENT ENGINE
# ============================================================

def enhance_product_image(
    image_bytes: bytes,
) -> str:

    if not image_bytes:

        raise ValueError(
            "Image data is empty."
        )

    # --------------------------------------------------------
    # OPEN IMAGE
    # --------------------------------------------------------

    try:

        image = Image.open(
            BytesIO(image_bytes)
        )

    except Exception as e:

        raise ValueError(
            f"Could not read image: {str(e)}"
        )

    # --------------------------------------------------------
    # DETECT FORMAT
    # --------------------------------------------------------

    detected_format = (
        image.format or "UNKNOWN"
    )

    print(
        f"Detected image format: "
        f"{detected_format}"
    )

    supported_formats = {
        "JPEG",
        "PNG",
        "WEBP",
        "BMP",
        "GIF",
        "TIFF",
    }

    if detected_format not in supported_formats:

        raise ValueError(
            f"Unsupported image format: "
            f"{detected_format}"
        )

    # --------------------------------------------------------
    # FIX ORIENTATION
    # --------------------------------------------------------

    image = ImageOps.exif_transpose(
        image
    )

    # --------------------------------------------------------
    # HANDLE ANIMATION / PALETTE
    # --------------------------------------------------------

    if image.mode in (
        "P",
        "LA",
    ):

        image = image.convert(
            "RGBA"
        )

    # --------------------------------------------------------
    # RGB CONVERSION
    # --------------------------------------------------------

    if image.mode != "RGB":

        if image.mode == "RGBA":

            background = Image.new(
                "RGB",
                image.size,
                "white",
            )

            background.paste(
                image,
                mask=image.getchannel(
                    "A"
                ),
            )

            image = background

        else:

            image = image.convert(
                "RGB"
            )

    # --------------------------------------------------------
    # RESIZE
    # --------------------------------------------------------

    max_dimension = 1800

    width, height = image.size

    if max(width, height) > max_dimension:

        scale = (
            max_dimension
            / max(width, height)
        )

        new_width = int(
            width * scale
        )

        new_height = int(
            height * scale
        )

        image = image.resize(
            (
                new_width,
                new_height,
            ),
            Image.Resampling.LANCZOS,
        )

    # --------------------------------------------------------
    # AUTO CONTRAST
    # --------------------------------------------------------

    image = ImageOps.autocontrast(
        image,
        cutoff=1,
    )

    # --------------------------------------------------------
    # LIGHTING
    # --------------------------------------------------------

    image = ImageEnhance.Brightness(
        image
    ).enhance(1.06)

    # --------------------------------------------------------
    # CONTRAST
    # --------------------------------------------------------

    image = ImageEnhance.Contrast(
        image
    ).enhance(1.12)

    # --------------------------------------------------------
    # COLOR
    # --------------------------------------------------------

    image = ImageEnhance.Color(
        image
    ).enhance(1.08)

    # --------------------------------------------------------
    # SHARPNESS
    # --------------------------------------------------------

    image = ImageEnhance.Sharpness(
        image
    ).enhance(1.35)

    # --------------------------------------------------------
    # DETAIL ENHANCEMENT
    # --------------------------------------------------------

    image = image.filter(
        ImageFilter.UnsharpMask(
            radius=1.2,
            percent=90,
            threshold=3,
        )
    )

    # --------------------------------------------------------
    # EXPORT TO JPEG
    # --------------------------------------------------------

    output = BytesIO()

    image.save(
        output,
        format="JPEG",
        quality=94,
        optimize=True,
    )

    enhanced_bytes = (
        output.getvalue()
    )

    # --------------------------------------------------------
    # BASE64
    # --------------------------------------------------------

    encoded = base64.b64encode(
        enhanced_bytes
    ).decode("utf-8")

    return (
        "data:image/jpeg;base64,"
        + encoded
    )


# ============================================================
# IMAGE ENHANCEMENT UPLOAD
# ============================================================

@app.post(
    "/ai/image-enhance-upload"
)
async def image_enhance_upload(
    product_name: str = Form(
        "HeriTrace Product"
    ),
    file: UploadFile = File(...),
):

    try:

        print(
            "=========================================="
        )

        print(
            "HERITRACE IMAGE ENHANCEMENT REQUEST"
        )

        print(
            f"Filename: {file.filename}"
        )

        print(
            f"Browser MIME type: "
            f"{file.content_type}"
        )

        # ----------------------------------------------------
        # READ FILE
        # ----------------------------------------------------

        contents = await file.read()

        print(
            f"Received bytes: "
            f"{len(contents)}"
        )

        # ----------------------------------------------------
        # EMPTY FILE
        # ----------------------------------------------------

        if not contents:

            raise HTTPException(
                status_code=400,
                detail="Image file is empty.",
            )

        # ----------------------------------------------------
        # SIZE LIMIT
        # ----------------------------------------------------

        max_size = (
            15 * 1024 * 1024
        )

        if len(contents) > max_size:

            raise HTTPException(
                status_code=400,
                detail=(
                    "Image is larger than "
                    "15 MB."
                ),
            )

        # ----------------------------------------------------
        # IMPORTANT:
        # DO NOT REJECT BASED ON BROWSER MIME TYPE.
        #
        # Flutter Web / Chrome can send:
        #
        # application/octet-stream
        #
        # even when the actual file is JPG/PNG/WEBP.
        #
        # Pillow detects the real image format.
        # ----------------------------------------------------

        try:

            test_image = Image.open(
                BytesIO(contents)
            )

            detected_format = (
                test_image.format
                or "UNKNOWN"
            )

            print(
                f"Detected format: "
                f"{detected_format}"
            )

            supported_formats = {
                "JPEG",
                "PNG",
                "WEBP",
                "BMP",
                "GIF",
                "TIFF",
            }

            if (
                detected_format
                not in supported_formats
            ):

                raise HTTPException(
                    status_code=400,
                    detail=(
                        "Unsupported image format: "
                        f"{detected_format}"
                    ),
                )

            # Verify image data
            test_image.verify()

        except HTTPException:
            raise

        except Exception as e:

            print(
                "IMAGE VALIDATION ERROR:",
                e,
            )

            raise HTTPException(
                status_code=400,
                detail=(
                    "The uploaded file is not "
                    "a valid JPG, PNG or WebP image."
                ),
            )

        # ----------------------------------------------------
        # ENHANCE IMAGE
        # ----------------------------------------------------

        enhanced_image = (
            enhance_product_image(
                contents
            )
        )

        print(
            "Image enhancement successful."
        )

        print(
            "=========================================="
        )

        # ----------------------------------------------------
        # RESPONSE
        # ----------------------------------------------------

        return {
            "success": True,
            "product_name":
                product_name,
            "filename":
                file.filename,
            "original_format":
                detected_format,
            "enhanced_image":
                enhanced_image,
            "message":
                "Image enhanced successfully.",
        }

    except HTTPException:
        raise

    except Exception as e:

        print(
            "IMAGE ENHANCEMENT ERROR:",
            e,
        )

        print(
            "=========================================="
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Image enhancement failed: "
                + str(e)
            ),
        )


# ============================================================
# BASE64 IMAGE ENHANCEMENT
# ============================================================

@app.post(
    "/ai/image-enhance"
)
def image_enhance(
    request: ImageEnhanceRequest,
):

    try:

        image_data = (
            request.image_base64
        )

        if "," in image_data:

            image_data = (
                image_data.split(
                    ",",
                    1,
                )[1]
            )

        image_bytes = (
            base64.b64decode(
                image_data
            )
        )

        enhanced_image = (
            enhance_product_image(
                image_bytes
            )
        )

        return {
            "success": True,
            "product_name":
                request.product_name,
            "enhanced_image":
                enhanced_image,
            "message":
                "Image enhanced successfully.",
        }

    except Exception as e:

        print(
            "BASE64 IMAGE ERROR:",
            e,
        )

        raise HTTPException(
            status_code=500,
            detail=(
                "Image enhancement failed: "
                + str(e)
            ),
        )


# ============================================================
# SPEECH TO TEXT
# ============================================================

@app.post(
    "/ai/speech-to-text"
)
def speech_to_text(
    request: SpeechRequest,
):

    text = request.text.strip()

    if not text:

        raise HTTPException(
            status_code=400,
            detail="Speech text is empty.",
        )

    return {
        "success": True,
        "text": text,
        "language":
            request.language,
        "message":
            "Speech processed successfully.",
    }


# ============================================================
# START SERVER
# ============================================================

if __name__ == "__main__":

    uvicorn.run(
        app,
        host="127.0.0.1",
        port=8000,
        reload=False,
    )
