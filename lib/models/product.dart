class Product {
  final String id,name,description,category; final double price;
  final String? imageUrl;
  Product({required this.id,required this.name,required this.description,required this.price,required this.category,this.imageUrl});
  Map<String,dynamic> toMap()=>{'name':name,'description':description,'price':price,'category':category,'imageUrl':imageUrl};
  factory Product.fromMap(String id,Map<String,dynamic> m)=>Product(id:id,name:m['name']??'',description:m['description']??'',price:(m['price']??0).toDouble(),category:m['category']??'Other',imageUrl:m['imageUrl']);
}
