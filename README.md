Modèle de base de donnée

events
String id
String title
DateTime creation_date
DateTime updated_date
DateTime start_at
DateTime end_at
String color

events_participation
String id
String userId
String eventId

family
String id
String userId
String familyId

friend
String id
String userId
String friendId

shared_agenda
String id
String title
String ownerId

shared_agenda_users
String id
String userId
String sharedAgendaId

Redirige vers création de compte après avoir cliquer sur le lien, et ensuite fait rejoindre
directement les amis dans l'application