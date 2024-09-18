part of 'barbershop.dart';


Barbershop _$BarbershopFromJson(Map<String, dynamic> json) => Barbershop(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      address: json['address'] as String? ?? 'No Address',
      x: (json['x'] as num?)?.toDouble(),
      y: (json['y'] as num?)?.toDouble(),
      tel: json['tel'] as String? ?? 'No Phone',
      thumUrl: json['thumUrl'] as String? ?? 'No Image',
      bizhourInfo: json['bizhourInfo'] as String? ?? 'No Business Hours Info',
      menuInfo: json['menuInfo'] as String? ?? 'No Menu Info',
      context: (json['context'] is String)
          ? (json['context'] as String).split(',') // Split by a comma or another delimiter if needed
          : (json['context'] as List<dynamic>?)?.map((e) => e as String).toList(),

);

Map<String, dynamic> _$BarbershopToJson(Barbershop instance) =>
    <String, dynamic>{
          'id' : instance.id,
          'name': instance.name,
          'address': instance.address,
          'x': instance.x,
          'y': instance.y,
          'tel': instance.tel,
          'thumUrl': instance.thumUrl,
          'bizhourInfo': instance.bizhourInfo,
          'menuInfo': instance.menuInfo,
          'context': instance.context,


    };
