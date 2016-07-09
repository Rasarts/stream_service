part of stream_service;

/// Миксин для создания события с подписью
/// и разсылки их объеектам-наблюдателям.
/// Объект может иметь список событий на которые может реагировать
/// и тогда наблюдаемые объекты перед отправкой события будут
/// проверять необходимость этого события для этого объекта.
class NotifyMixin {
  Stream stream;
  StreamController controller;

  /// Список наблюдателей
  List<StreamService> observers = new List();

  /// Список наблюдаемых объектов
  List<StreamService> observables = new List();

  /// Список ожидаемых объектом событий
  List<String> treatmentEvents = new List();

  /// Список создаваемых объектом событий
  List<String> generatedEvents = new List();

  /// Создание события и подписи к нему.
  /// Распространение события каждому наблюдающему объекту.
  dispatchEvent(String message, [dynamic details]) {
    Map detail = new Map(); // Детали события
    detail['message'] = message;
    detail['details'] = details;

    /// Добавление подписи события в
    /// список создаваемых объектом событий.
    if (!generatedEvents.contains(message)) {
      generatedEvents.add(message);
    }

    /// Добавление события в свой собственный поток.
    /// Иногда события внутри обекта не должны
    /// обрабатываться где-нибудь кроме
    /// как самим объектом.
    controller.add(detail);

    /// Когда наблюдаемый объект создает событие
    /// наблюдатели должны его получить.
    observers.forEach((StreamService observableObjectStream) {
      observableObjectStream.controller.add(detail);
    });
  }

  /// Подписка на событие обработчика
  on(String message, Function handler) {
    /// Добавление подписи обрабатываемого события в
    /// список ожидаемых объектом событий.
    /// Нужно проверять этот список объектов
    /// наблюдателей переод отправкой события.
    if (!treatmentEvents.contains(message)) {
      treatmentEvents.add(message);
    }

    /// Обработчики события подписываются
    /// на собственный поток.
    /// Потому как сюда будут публиковаться события
    /// из наблюдаемых объектов.
    stream.listen((Map data) {
      if (data['message'] == message) {
        Map details = data['details'];
        handler(details);
      }
    });
  }
}
