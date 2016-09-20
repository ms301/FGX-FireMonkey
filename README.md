# FGX-FireMonkey
Набор дополнительных компонентов для FireMonkey.

## Описание

Эта версия включает в себя следующий набор компонентов:

* [**Дизайнер итемов**](http://fire-monkey.ru/topic/1355-opisanie-redaktora-itemov/) - дизайнер итемов.
* [**TfgToast**](http://fire-monkey.ru/topic/1904-opisanie-tfgtoast-bystrye-uvedomleniia/#entry9976) (UPDATED) - класс отображения быстрых сообщений
* [**TfgFlipView**](http://fire-monkey.ru/topic/996-opisanie-tfgflipview-slaider-izobrazhenii/) - слайдер изображений. Поддерживает несколько способов переключения фотографий при помощи эффектов и сдвигов. При первом использовании ОБЯЗАТЕЛЬНО прочитать инструкцию ["TfgFlipView - Инструкция загрузки стиля"](http://fire-monkey.ru/topic/1054-tfgflipview-instruktciia-zagruzki-stilia/)
* **TfgPositionAnimation** - анимация свойств типа TPosistion
* **TfgPosition3DAnimation** - анимация свойств типа TPosition3D 
* **TfgBitmapLinkAnimation** - анимация свойств типа TBitmapLink 
- [**TfgProgressDialog**](http://fire-monkey.ru/topic/594-opisanie-tfgprogressdialog/#entry2415) (UPDATED) - Компонент для отображения диалогового окна в момент выполнения длительной фоновой операции, когда время выполнения фоновой операции можно оценить.
- [**TfgActivityDialog**](http://fire-monkey.ru/topic/593-opisanie-tfgactivitydialog/) (UPDATED) - компонент для отображения диалогового окна в момент выполнения длительной фоновой операции, когда время выполнения операции не возможно адекватно оценить.
- **TfgActionSheet** (UPDATED) - Аналог контекстного меню для мобильных платформ.
- [**TfgColorsPanel**](http://fire-monkey.ru/topic/597-opisanie-tfgcolorspanel/#entry2419) - Палитра цветов с возможностью выбора цвета.
- **TfgGradientEdit** (UPDATED) - Компонент выбора градиента.
- **TfgLinkedLabel** (UPDATED) - Метка поддерживающая открытие Web ссылки в браузере по умолчанию.
- [**TfgApplicationEvents**](http://fire-monkey.ru/topic/1055-opisanie-tfgapplicationevents-monitoring-osnovnykh-sobytii-pril/) (UPDATED) - компонент с возможностью легко задать обработчики на основные события приложения: Отслеживание смены состояния приложения, простой, обновление и выполнение действий Actions, Изменение ориентации устройства и тд.
- **TfgVirtualKeyboard** (UPDATED) - компонент облегчающий работу с виртуальной клавиатурой. Позволяет задать пользовательские кнопки над виртуальной клавиатурой под iOS, а так же отлавливать события по отображению и скрытию клавиатуры.
* (UPDATED) Зарегистрированы все стилевые объекты на вкладке "FGX: Style objects"

## Список изменений

* [**TfgActionSheet**]: 
  * Добавлен новый вариант темы Theme = Custom и свойство ThemeID, позволяющий для андроида указать идентификатор своей темы диалога. Теперь доступна возможность создать свой вариант диалога для андроида.
  * Изменен порядок срабатывания событий OnCancel, OnHide в реализации на iOS. Раньше срабатывали OnHide -> OnCancel, Теперь: OnCancel -> OnHide
  * Обновлен пример
  * Общие улучшения в читабельности кода
* **TfgProgressDialog, TfgActivityDialog**:
  * Добавлен новый вариант темы Theme = Custom и свойство ThemeID, позволяющий для андроида указать идентификатор своей темы диалога.
  * Обновлен пример
  * Общие улучшения в читабельности кода
* **TfgGradientEdit**:
  * Добавлено событие OnPointRemoved, срабатывающее, когда точка удалена из градиента.
  * Обновлен пример
* **TfgToast**:
  * Исправлена ошибка на iOS, приводящая к AV при многочисленном отображении тостов. ([Спасибо Сергею Пьянкову за найденную ошибку](http://fire-monkey.ru/topic/1904-%D0%BE%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5-tfgtoast-%D0%B1%D1%8B%D1%81%D1%82%D1%80%D1%8B%D0%B5-%D1%83%D0%B2%D0%B5%D0%B4%D0%BE%D0%BC%D0%BB%D0%B5%D0%BD%D0%B8%D1%8F/?do=findComment&comment=18886))
* **Регистрация стилевых объектов**:
  * Теперь регистрируются только те объекты, которые не добавлены в палитру.

[Delphinus](http://memnarch.bplaced.net/blog/2015/08/delphinus-packagemanager-for-delphi-xe-and-newer/)-Support was added.
