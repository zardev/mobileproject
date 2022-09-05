import 'dart:async';

abstract class CrudService<T> {
  Future<List<T>> getAll();

  Future<T?> getOneById(String id);

  Future<T> create(T entity);

  Future<void> update(T entity);

  Future<bool> delete(String id);
}
