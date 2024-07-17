# <img src="/assets/app_icons/light/app_logo_light.png" width=50 alt="logo"> DementiApp - ToDO-like для тех, кто вечно забывает таски

#### Ссылочка на загрузочку -> https://disk.yandex.ru/d/kdyErSRqjjG2aw

## 🤔 Зачем? 
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

### Crashlytics:
<img src="/assets/app_samples/crashlytics.png" alt="Crash" width="900"/> 
<img src="/assets/app_samples/crashlytics2.png" alt="Crash" width="900"/>

### Analytics:
<img src="/assets/app_samples/analytics1.png" alt="Crash" width="900"/>
<img src="/assets/app_samples/analytics2.png" alt="Crash" width="900"/>

### Overview gallery:
<img src="/assets/app_samples/dark1.png" alt="ToDo create" width="400"/> <img src="/assets/app_samples/dark2.png" alt="ToDo create" width="400"/>
<img src="/assets/app_samples/dark3.png" alt="ToDo create" width="400"/> <img src="/assets/app_samples/dark4.png" alt="ToDo create" width="400"/>
<img src="/assets/app_samples/dark5.png" alt="ToDo create" width="400"/> <img src="/assets/app_samples/dark6.png" alt="ToDo create" width="400"/>
<img src="/assets/app_samples/dark7.png" alt="ToDo create" width="400"/> <img src="/assets/app_samples/dark8.png" alt="ToDo create" width="400"/>

### Tablet:
<img src="/assets/app_samples/tablet1.png" alt="ToDo create" width="400"/>
<img src="/assets/app_samples/tablet2.png" alt="ToDo create" width="400"/>
<img src="/assets/app_samples/tablet3.png" alt="ToDo create" width="400"/>


#### Реализованные фичи:
🔥 - новое

- **UI:**
    + Экран со списком дел
    + Экран для добавления/редактирования дела
    + 🔥 Landscape orientation
    + 🔥 Tablet support
    + 🔥 Night theme
    + 🔥 Floating action button animation
    + 🔥 Transition animations
- **Работа с сетью:**
    + Offline-first 
    + Dio
    + connectivity_plus (для прослушивания соединения)
- **Работа с локальным источником:**
    + SQFlite
- **Тесты:**
    + Unit (для класса репозитория и локального источника)
    + Integrated (сценарий навигирования на экран добавления дела)
- **Навигация:**
    + Navigator 2.0 - Go_router
    + deeplink:
        * cmd: adb shell am start -a android.intent.action.VIEW -d "dementiapp://dementia.pp/add_new" dementia.pp
- **DI:**
    + Get_it
    + injectable
- **FIREBASE:**
    + 🔥 Firebase-crashlytics
    + 🔥 Firebase-analytics
- **CI/CD:**
    + 🔥 GitHub actions
- **State-manager:**
    + BLoC
- **Локализация:**
    + intl
    + l10n
- **Архитектура:**
    + Clean Architechture
    + feature-first