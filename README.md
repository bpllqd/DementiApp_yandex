# <img src="/assets/app_icons/light/app_logo_light.png" width=50 alt="logo"> DementiApp - ToDO-like для тех, кто вечно забывает таски

#### Ссылочка на загрузку ->  https://disk.yandex.ru/d/vMg7j3Fiep1cIw

## Inovation
<br>
Dementiapp - приложение-второй мозг! С его помощью вы с легкостью освободите голову от ненужных забот,
достаточно в пару тапов записать дело и вы его не забудете!

## Features:
### Экран "Мои дела"

<img src="/assets/app_samples/todo_list_sample.png" alt="ToDo list" width="400"/> 
<br>

Данный экран предоставляет информацию о списке дел: выполненных/невыполненных, срочных/несрочных. Есть возможность фильтровать задачи на предмет готовности, отмечать задачи выполненными, отмечать задачи невыполненными, а также их удалять. Присутствует кнопка + для добавления новых задач.

### Экран "Добавления/Редактирования дела"

<img src="/assets/app_samples/todo_create_sample.png" alt="ToDo create" width="400"/>  

Данный экран предоставляет интерфейс для добавления/редактирования дел. Есть возможность написать задачу, выбрать для нее приоритет (default: no), а также опционально задать deadline. В случае, если происходит редактирование уже существующей задачи, появляется возможность ее удалить.

#### Реализованные фичи:
[+] UI
[+] Offline-first + caching data
[+] Listen to internet connection (connectivity_plus)
[+] Repo, Local with unit-test
[+] 1 integration test (opening create task screen)
[+] Routing: Navigator 2.0 (go_router)
[+] DI: Get_it + injectable
[+] State-manager: BLoC
[+] Local datasource: SQFlite
[+] Remote datasource: Dio
[+] Localization: intl
[+] File-structure: faeture-first
[+] Architechture: clean