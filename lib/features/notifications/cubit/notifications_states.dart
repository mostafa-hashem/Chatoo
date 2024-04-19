abstract class NotificationsStates {}

class NotificationsInitial extends NotificationsStates {}

class NotificationsLoading extends NotificationsStates {}

class NotificationsSuccess extends NotificationsStates {}

class NotificationsError extends NotificationsStates {
  final String message;

  NotificationsError(this.message);
}

class SendNotificationLoading extends NotificationsStates {}

class SendNotificationSuccess extends NotificationsStates {}

class SendNotificationError extends NotificationsStates {
  final String message;

  SendNotificationError(this.message);
}
