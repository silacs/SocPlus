class Paginated<T> {
  final int page;
  final int pageSize;
  final int skip;
  final int total;
  List<T> data;
  Paginated({required this.page, required this.pageSize, required this.skip, required this.total, required this.data});
  factory Paginated.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>) serializer) {
    List<T> data = [];
    for (var item in json['data']) {
      data.add(serializer(item));
    }
    return Paginated(
      page: json['page'],
      pageSize: json['pageSize'],
      skip: json['skip'],
      total: json['total'],
      data: data
    );
  }
}