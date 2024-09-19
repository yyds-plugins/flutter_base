extension Iterables<E> on Iterable<E> {
  Map<K, List<E>> groupBy<K>(K Function(E) keyFunction) =>
      fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) => map..putIfAbsent(keyFunction(element), () => <E>[]).add(element));

  Map<K, List<E>> groupByStringEquality<K>(K Function(E) keyFunction) {
    return fold(<K, List<E>>{}, (Map<K, List<E>> map, E element) {
      final key = keyFunction(element);
      map.putIfAbsent(key, () => <E>[]).add(element);
      return map;
    });
  }
}
