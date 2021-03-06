﻿Перем ТекстовыйФайл, Таб;
Перем ОбщийЗапрос;
Перем СкладМагазины, СписокФайлов, ТекущаяГруппаНоменклатуры;
Перем СтруктураПараметров;

#Область ВСПОМОГАТЕЛЬНЫЕ_ПРОЦЕДУРЫ_И_ФУНКЦИИ

Функция ПолучитьСписокДоступныхВнешнихСистем() экспорт
	
	СписокДоступныхВнешнихСистем = Новый СписокЗначений;
	Выборка = Справочники.ВнешниеСистемы.Выбрать(Справочники.ВнешниеСистемы.НайтиПоКоду("000000040"));
	Пока Выборка.Следующий() цикл
		СписокДоступныхВнешнихСистем.Добавить(Выборка.Ссылка);
	КонецЦикла;	
	
	Возврат СписокДоступныхВнешнихСистем;
	
КонецФункции

Процедура ИнициализацияПараметровВнешнейСистемы()
	
	СтруктураПараметров = Новый Структура;
	// Запишем в структуру все ключи из внешней системы
	Для Каждого КлючИЗначение из ВнешняяСистема.Ключи цикл
		
		СтруктураПараметров.Вставить(КлючИЗначение.Наименование, КлючИЗначение.Значение);
		
	КонецЦикла;	
	
	// Запишем в структуру массив складов из внешней системы
	СтруктураПараметров.Склады = ВнешняяСистема.Склады.ВыгрузитьКолонку("Склад");
	
	// Запишем в структуру массив организаций из внешней системы
	СтруктураПараметров.Организации = ВнешняяСистема.Организации.ВыгрузитьКолонку("Организация");
	
	// Запишем в структуру массив групп номенклатур из внешней системы
	СтруктураПараметров.Организации = ВнешняяСистема.НоменклатурныеГруппы.ВыгрузитьКолонку("Группа");	
		
КонецПроцедуры	

Процедура ОбщийЗапрос()
	
	ОбщийЗапрос = Новый Запрос;
	ОбщийЗапрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	ОбщийЗапрос.Текст = "
	|////////////////////////////////////////////////////////////////////////////////
	|//////////////////////////  ВСЕ ДВИЖЕНИЯ ЗА ПЕРИОД  ////////////////////////////
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ЗапасыНаСкладах.Период КАК Период,
	|	ЗапасыНаСкладах.Регистратор КАК Регистратор,
	|	ЗапасыНаСкладах.Номенклатура КАК Номенклатура,
	|	СУММА(ЗапасыНаСкладах.КоличествоОборот) КАК Количество
	|ПОМЕСТИТЬ ВТ_ДвиженияЗапасов
	|ИЗ
	|	РегистрНакопления.ЗапасыНаСкладах.Обороты(
	|		&НачалоПериода,
	|		&КонецПериода,
	|		Запись,
	|		Номенклатура В ИЕРАРХИИ (&ТекущаяГруппа)
	|			И НЕ Склад В (&Магазины)
	|	) КАК ЗапасыНаСкладах
	|ГДЕ
	|	НЕ ЗапасыНаСкладах.Регистратор ССЫЛКА Документ.КорректировкаЗаписейРегистров
	|		И НЕ ЗапасыНаСкладах.Регистратор ССЫЛКА Документ.КорректировкаЗаписейРегистровНакопления
	|		И НЕ ЗапасыНаСкладах.Регистратор ССЫЛКА Документ.КорректировкаКачестваЗапасов
	|СГРУППИРОВАТЬ ПО
	|	ЗапасыНаСкладах.Период,
	|	ЗапасыНаСкладах.Регистратор,
	|	ЗапасыНаСкладах.Номенклатура
	|ИНДЕКСИРОВАТЬ ПО
	|	Регистратор,
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|//////  СООТВЕТСТВИЯ - ""ОСНОВНЫЕ"" ДОКУМЕНТЫ ДЛЯ КАЖДОГО РЕГИСТРАТОРА /////////
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ.Регистратор КАК Регистратор,
	|	ВЫБОР
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ОтгрузкаТоваровУслуг
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ВозвратТоваровОтПокупателя
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ОприходованиеТоваров
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.СписаниеТоваров
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ПеремещениеТоваров
	|			ТОГДА ВТ.Регистратор
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ИнвентаризацияДоставки
	|			ТОГДА ВТ.Регистратор.ДокументОтгрузки
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.РасходныйСкладскойОрдер
	|			ТОГДА ВТ.Регистратор.ДокументОснование
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ЕСТЬNULL(ВТ.Регистратор.ДокументОснование.Номер, ""0"") <> ""0""
	|			ТОГДА ВТ.Регистратор.ДокументОснование
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ПТУПоПСО.ПТУ ЕСТЬ НЕ NULL
	|			ТОГДА ПТУПоПСО.ПТУ
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ВозвратыПоПСО.Возврат ЕСТЬ НЕ NULL
	|			ТОГДА ВозвратыПоПСО.Возврат
	|		ИНАЧЕ ВТ.Регистратор
	|	КОНЕЦ КАК ЗаказПокупателя,
	|	МИНИМУМ(ВТ.Период) КАК Период
	|ПОМЕСТИТЬ ВТ_СоответствияРегистраторовЗаказам
	|ИЗ
	|	ВТ_ДвиженияЗапасов КАК ВТ
	|		ЛЕВОЕ СОЕДИНЕНИЕ (
	|			ВЫБРАТЬ
	|				Товары.ПриходныйОрдер,
	|				МАКСИМУМ(Товары.Ссылка) КАК ПТУ
	|			ИЗ
	|				Документ.ПоступлениеТоваровУслуг.Товары КАК Товары
	|			СГРУППИРОВАТЬ ПО
	|				Товары.ПриходныйОрдер
	|		) КАК ПТУПоПСО
	|			ПО ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|				И ВТ.Регистратор = ПТУПоПСО.ПриходныйОрдер
	|		ЛЕВОЕ СОЕДИНЕНИЕ (
	|			ВЫБРАТЬ
	|				Товары.ПриходныйОрдер,
	|				МАКСИМУМ(Товары.Ссылка) КАК Возврат
	|			ИЗ
	|				Документ.ВозвратТоваровОтПокупателя.Товары КАК Товары
	|			СГРУППИРОВАТЬ ПО
	|				Товары.ПриходныйОрдер
	|		) КАК ВозвратыПоПСО
	|			ПО ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|				И ВТ.Регистратор = ВозвратыПоПСО.ПриходныйОрдер
	|СГРУППИРОВАТЬ ПО
	|	ВТ.Регистратор,
	|	ВЫБОР
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ОтгрузкаТоваровУслуг
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ВозвратТоваровОтПокупателя
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ОприходованиеТоваров
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.СписаниеТоваров
	|			ИЛИ ВТ.Регистратор ССЫЛКА Документ.ПеремещениеТоваров
	|			ТОГДА ВТ.Регистратор
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ИнвентаризацияДоставки
	|			ТОГДА ВТ.Регистратор.ДокументОтгрузки
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.РасходныйСкладскойОрдер
	|			ТОГДА ВТ.Регистратор.ДокументОснование
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ЕСТЬNULL(ВТ.Регистратор.ДокументОснование.Номер, ""0"") <> ""0""
	|			ТОГДА ВТ.Регистратор.ДокументОснование
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ПТУПоПСО.ПТУ ЕСТЬ НЕ NULL
	|			ТОГДА ПТУПоПСО.ПТУ
	|		КОГДА ВТ.Регистратор ССЫЛКА Документ.ПриходныйСкладскойОрдер
	|			И ВозвратыПоПСО.Возврат ЕСТЬ НЕ NULL
	|			ТОГДА ВозвратыПоПСО.Возврат
	|		ИНАЧЕ ВТ.Регистратор
	|	КОНЕЦ	
	|ИНДЕКСИРОВАТЬ ПО
	|	Регистратор,
	|	ЗаказПокупателя
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|////////////////  ПОЛНАЯ ТАБЛИЦА С ИНФОРМАЦИЕЙ ПО ОТГРУЗКАМ  ///////////////////
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	Документы.ЗаказПокупателя КАК ДокументСсылка,
	|	Документы.ЗаказПокупателя.Контрагент КАК Контрагент,
	|	Документы.ЗаказПокупателя.СтруктурнаяЕдиницаКонтрагента КАК СтруктурнаяЕдиницаКонтрагента,
	|	Документы.ЗаказПокупателя.Ответственный.ФизЛицо КАК ТорговыйПредставитель,
	|	Движ.Номенклатура КАК Номенклатура,
	|	Движ.Количество КАК Количество,
	|	ВЫБОР
	|		КОГДА ЕСТЬNULL(ТЧ.Цена, 0) = 0
	|	   	ТОГДА 0
	|		ИНАЧЕ ТЧ.Цена
	|	КОНЕЦ КАК Цена,
	|//	ЕСТЬNULL(ТЧ.Цена, 0) КАК Цена,
	|	ЕСТЬNULL(ТЧ.СтавкаНДС, &СтавкаБезНДС) КАК СтавкаНДС,
	|	Движ.Период КАК Период,
	|	ВЫБОР
	|		КОГДА Документы.ЗаказПокупателя ССЫЛКА Документ.ОтгрузкаТоваровУслуг
	|			ИЛИ Документы.ЗаказПокупателя ССЫЛКА Документ.ВозвратТоваровОтПокупателя
	|			ТОГДА Истина
	|		ИНАЧЕ Ложь
	|	КОНЕЦ КАК Реализация
	|ПОМЕСТИТЬ
	|	ВТ_ВсеОтгрузки
	|ИЗ
	|	ВТ_ДвиженияЗапасов КАК Движ
	|		СОЕДИНЕНИЕ ВТ_СоответствияРегистраторовЗаказам КАК Документы
	|			ПО Документы.Регистратор = Движ.Регистратор
	|		ЛЕВОЕ СОЕДИНЕНИЕ (
	|			ВЫБРАТЬ
	|				ТабЧасть.Ссылка КАК Ссылка,
	|				ТабЧасть.Номенклатура КАК Номенклатура,
	|				СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент) КАК Количество,
	|				ВЫРАЗИТЬ(
	|					ВЫБОР
	|						КОГДА ТабЧасть.Ссылка.СуммаВключаетНДС ТОГДА СУММА(ТабЧасть.Сумма)
	|						ИНАЧЕ СУММА(ТабЧасть.Сумма+ТабЧасть.СуммаНДС)
	|					КОНЕЦ
	|						/ СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент)
	|				КАК ЧИСЛО(15,2)) КАК Цена,
	|//				МАКСИМУМ(ТабЧасть.Цена) КАК Цена,
	|				МАКСИМУМ(ТабЧасть.СтавкаНДС) КАК СтавкаНДС
	|			ИЗ
	|				Документ.ОтгрузкаТоваровУслуг.Товары КАК ТабЧасть
	|			СГРУППИРОВАТЬ ПО
	|				ТабЧасть.Ссылка,
	|				ТабЧасть.Номенклатура
	|
	|			ОБЪЕДИНИТЬ ВСЕ
	|
	|			ВЫБРАТЬ
	|				ТабЧасть.Ссылка КАК Ссылка,
	|				ТабЧасть.Номенклатура КАК Номенклатура,
	|				СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент) КАК Количество,
	|				ВЫРАЗИТЬ(
	|					ВЫБОР
	|						КОГДА ТабЧасть.Ссылка.СуммаВключаетНДС ТОГДА СУММА(ТабЧасть.Сумма)
	|						ИНАЧЕ СУММА(ТабЧасть.Сумма+ТабЧасть.СуммаНДС)
	|					КОНЕЦ
	|						/ СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент)
	|				КАК ЧИСЛО(15,2)) КАК Цена,
	|//				МАКСИМУМ(ТабЧасть.Цена) КАК Цена,
	|				МАКСИМУМ(ТабЧасть.СтавкаНДС) КАК СтавкаНДС
	|			ИЗ
	|				Документ.ВозвратТоваровОтПокупателя.Товары КАК ТабЧасть
	|			СГРУППИРОВАТЬ ПО
	|				ТабЧасть.Ссылка,
	|				ТабЧасть.Номенклатура
	|
	|			ОБЪЕДИНИТЬ ВСЕ
	|
	|			ВЫБРАТЬ
	|				ТабЧасть.Ссылка КАК Ссылка,
	|				ТабЧасть.Номенклатура КАК Номенклатура,
	|				СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент) КАК Количество,
	|				МАКСИМУМ(ТабЧасть.Цена) КАК Цена,
	|				МАКСИМУМ(ТабЧасть.СтавкаНДС) КАК СтавкаНДС
	|			ИЗ
	|				Документ.ПоступлениеТоваровУслуг.Товары КАК ТабЧасть
	|			СГРУППИРОВАТЬ ПО
	|				ТабЧасть.Ссылка,
	|				ТабЧасть.Номенклатура
	|
	|			ОБЪЕДИНИТЬ ВСЕ
	|
	|			ВЫБРАТЬ
	|				ТабЧасть.Ссылка КАК Ссылка,
	|				ТабЧасть.Номенклатура КАК Номенклатура,
	|				СУММА(ТабЧасть.Количество*ТабЧасть.Коэффициент) КАК Количество,
	|				МАКСИМУМ(ТабЧасть.Цена) КАК Цена,
	|				МАКСИМУМ(ТабЧасть.СтавкаНДС) КАК СтавкаНДС
	|			ИЗ
	|				Документ.ВозвратТоваровПоставщику.Товары КАК ТабЧасть
	|			СГРУППИРОВАТЬ ПО
	|				ТабЧасть.Ссылка,
	|				ТабЧасть.Номенклатура
	|			
	|		) КАК ТЧ
	|			ПО ТЧ.Ссылка = Документы.ЗаказПокупателя
	|				И ТЧ.Номенклатура = Движ.Номенклатура
	|ИНДЕКСИРОВАТЬ ПО
	|	Реализация,
	|	ДокументСсылка,
	|	Контрагент,
	|	СтруктурнаяЕдиницаКонтрагента,
	|	ТорговыйПредставитель,
	|	Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ РАЗЛИЧНЫЕ ДокументСсылка КАК ДокументПродажи
	|ПОМЕСТИТЬ ВТ_ВсеДокументыПоПокупателям
	|ИЗ ВТ_ВсеОтгрузки КАК ВТ
	|ГДЕ ВТ.Реализация
	|ИНДЕКСИРОВАТЬ ПО
	|ДокументПродажи
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|//////////////////  ТАБЛИЦА ТОРГОВЫХ ТОЧЕК ИЗ РЕАЛИЗАЦИИ  //////////////////////
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВЫРАЗИТЬ(ВТ.Контрагент КАК Справочник.Контрагенты) КАК Контрагент,
	|	ВЫРАЗИТЬ(ВТ.СтруктурнаяЕдиницаКонтрагента КАК Справочник.СтруктурныеЕдиницыКонтрагентов) КАК ТорговаяТочка,
	|	МАКСИМУМ(ВТ.ТорговыйПредставитель) КАК ТорговыйПредставитель,
	|	ВТ.Контрагент.Код + ВЫБОР КОГДА ВТ.СтруктурнаяЕдиницаКонтрагента.Код ЕСТЬ NULL ТОГДА """" ИНАЧЕ ""-"" + ВТ.СтруктурнаяЕдиницаКонтрагента.Код КОНЕЦ КАК Client_Code,
	|	ПОДСТРОКА(ВТ.Контрагент.Наименование, 1, 200) + ВЫБОР КОГДА ВТ.СтруктурнаяЕдиницаКонтрагента.Код ЕСТЬ NULL ТОГДА """" ИНАЧЕ "" - "" + ПОДСТРОКА(ВТ.СтруктурнаяЕдиницаКонтрагента.Наименование, 1, 200) КОНЕЦ  КАК Client_Name,
	|	МАКСИМУМ(ЕСТЬNULL(Адреса.Регион,"""")) КАК Client_obl,
	|	МАКСИМУМ(
	|		ВЫБОР
	|			КОГДА ЕСТЬNULL(Адреса.Город,"""") <> """" ТОГДА Адреса.Город
	|			КОГДА ЕСТЬNULL(Адреса.НаселенныйПункт,"""") <> """" ТОГДА Адреса.НаселенныйПункт
	|			ИНАЧЕ """"
	|		КОНЕЦ
	|	) КАК Client_city,
	|	МАКСИМУМ(ВЫБОР
	|		КОГДА ЕСТЬNULL(Адреса.Улица,"""") = """"
	|			ТОГДА ВТ.СтруктурнаяЕдиницаКонтрагента.Наименование
	|		ИНАЧЕ
	|			ВЫБОР КОГДА ЕСТЬNULL(Адреса.Город,"""") = """"
	|				ТОГДА ВЫБОР КОГДА ЕСТЬNULL(Адреса.НаселенныйПункт,"""") = """" ТОГДА """" ИНАЧЕ Адреса.НаселенныйПункт + "", "" КОНЕЦ
	|				ИНАЧЕ Адреса.Город + "", ""
	|			КОНЕЦ
	|			+ Адреса.Улица
	|			+ ВЫБОР КОГДА ЕСТЬNULL(Адреса.Дом,"""") = """" ТОГДА """" ИНАЧЕ "", "" + Адреса.Дом КОНЕЦ
	|			+ ВЫБОР КОГДА ЕСТЬNULL(Адреса.Корпус,"""") = """" ТОГДА """" ИНАЧЕ ""/"" + Адреса.Корпус КОНЕЦ
	|	КОНЕЦ) КАК Client_Address,
	|	МАКСИМУМ(ВТ.ТорговыйПредставитель.Код) КАК AgentId,
	|	ВТ.Контрагент.ИНН КАК INN
	|ПОМЕСТИТЬ ВТ_ТорговыеТочкиПокупателей
	|ИЗ
	|	ВТ_ВсеОтгрузки КАК ВТ
	| 	ЛЕВОЕ СОЕДИНЕНИЕ (
	|		ВЫБРАТЬ
	|			Адреса.Объект КАК ОбъектСсылка,
	|			Адреса.Вид КАК ВидАдреса,
	|			МАКСИМУМ(Адреса.Поле1) КАК ПочтовыйИндекс,
	|			МАКСИМУМ(Адреса.Поле2) КАК Регион,
	|			МАКСИМУМ(Адреса.Поле3) КАК Район,
	|			МАКСИМУМ(Адреса.Поле4) КАК Город,
	|			МАКСИМУМ(Адреса.Поле5) КАК НаселенныйПункт,
	|			МАКСИМУМ(Адреса.Поле6) КАК Улица,
	|			МАКСИМУМ(Адреса.Поле7) КАК Дом,
	|			МАКСИМУМ(Адреса.Поле8) КАК Корпус,
	|			МАКСИМУМ(Адреса.Поле9) КАК Квартира,
	|			МАКСИМУМ(ВЫРАЗИТЬ(Адреса.Представление КАК Строка(255))) КАК Представление
	|		ИЗ
	|			РегистрСведений.КонтактнаяИнформация КАК Адреса
	|		ГДЕ
	|			Адреса.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.Адрес)
	|		СГРУППИРОВАТЬ ПО
	|			Адреса.Объект,
	|			Адреса.Вид
	|	) КАК Адреса
	|		ПО Адреса.ОбъектСсылка = ВЫБОР
	|				КОГДА ЕСТЬNULL(ВТ.СтруктурнаяЕдиницаКонтрагента, ЗНАЧЕНИЕ(Справочник.СтруктурныеЕдиницыКонтрагентов.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.СтруктурныеЕдиницыКонтрагентов.ПустаяСсылка) ТОГДА ВТ.Контрагент
	|				ИНАЧЕ ВТ.СтруктурнаяЕдиницаКонтрагента
	|			КОНЕЦ
	|			И Адреса.ВидАдреса = ВЫБОР
	|				КОГДА ЕСТЬNULL(ВТ.СтруктурнаяЕдиницаКонтрагента, ЗНАЧЕНИЕ(Справочник.СтруктурныеЕдиницыКонтрагентов.ПустаяСсылка)) = ЗНАЧЕНИЕ(Справочник.СтруктурныеЕдиницыКонтрагентов.ПустаяСсылка) ТОГДА &ВидАдресДоставкиКонтрагента
	|				ИНАЧЕ &ВидАдресСтруктурнойЕдиницы
	|			КОНЕЦ
	|ГДЕ
	|	ВТ.Реализация
	|СГРУППИРОВАТЬ ПО
	|	ВТ.Контрагент,
	|	ВТ.СтруктурнаяЕдиницаКонтрагента
	|ИНДЕКСИРОВАТЬ ПО
	|	Контрагент,
	|	ТорговаяТочка
	|;
	|
	|";
	
	ОбщийЗапрос.УстановитьПараметр("НачалоПериода", НачалоДня(ДатаНач));
	ОбщийЗапрос.УстановитьПараметр("КонецПериода", КонецДня(ДатаКон));
	ОбщийЗапрос.УстановитьПараметр("ТекущаяГруппа", ТекущаяГруппаНоменклатуры);
	ОбщийЗапрос.УстановитьПараметр("Магазины", СкладМагазины);
	ОбщийЗапрос.УстановитьПараметр("ВидАдресСтруктурнойЕдиницы", Справочники.ВидыКонтактнойИнформации.АдресСтруктурнойЕдиницыКонтрагента);
	ОбщийЗапрос.УстановитьПараметр("ВидАдресДоставкиКонтрагента", Справочники.ВидыКонтактнойИнформации.ФактАдресКонтрагента);
	ОбщийЗапрос.УстановитьПараметр("СтавкаБезНДС", Перечисления.СтавкиНДС.БезНДС);
	ОбщийЗапрос.Выполнить();

КонецПроцедуры	

Процедура УстановитьНастройкиПериода()
	
	Если НЕ СтруктураПараметров.Свойство("КоличествоДнейДляСреза") тогда
		ВызватьИсключение "У внешней системы '"+ВнешняяСистема.Наименование+"' не найден ключ 'КоличествоДнейДляСреза'";
	КонецЕсли;	
	
	ДатаНач = НачалоДня(ТекущаяДата() - 86400 * СтруктураПараметров.КоличествоДнейДляСреза);
	ДатаКон = НачалоДня(ТекущаяДата());
	
	Если День(ТекущаяДата()) = 5 тогда
		
		ДатаНач = НачалоМесяца(ОбщиеФункции.ДобавитьДень(ТекущаяДата(), -6));
		ДатаКон = КонецДня(ТекущаяДата());
		
	КонецЕсли;	
	
	Если ДатаНач < НачалоГода(ТекущаяДата()) тогда
		ДатаНач = НачалоГода(ТекущаяДата());
	КонецЕсли;		
	
КонецПроцедуры	

#КонецОбласти 

#Область РАБОТА_С_ФАЙЛАМИ

Процедура ДанныеПервогоЛиста()
	
	//Добавим строка с шапкой
	
	ТекстовыйФайл.ДобавитьСтроку("ИНН"+Таб+"Дистрибьютер"+Таб+"Дата начало"+Таб+"Дата конец"+Таб+"Склад"+Таб+"Название склада"+Таб+"Почта"+Таб);
	
	//Строка с детализацией
	СтрокаДанных = СтруктураПараметров.Организация.Инн + Таб
	+ СтруктураПараметров.Организация.НаименованиеПолное + Таб
	+ Формат(ДатаНач, "ДФ=dd.MM.yyyy") + Таб
	+ Формат(ДатаКон, "ДФ=dd.MM.yyyy") + Таб
	+ "0" + Таб
	+ "Основной склад"+Таб+"mail"+Таб;
	
	ТекстовыйФайл.ДобавитьСтроку(СтрокаДанных);
			
КонецПроцедуры	

Процедура ДанныеВторогоЛиста()
	
	ОбщийЗапрос.Текст = "ВЫБРАТЬ
	                    |	Все_Отгрузки.ДокументСсылка.Номер КАК ИД_Операции,
	                    |	НАЧАЛОПЕРИОДА(Все_Отгрузки.Период, ДЕНЬ) КАК ДатаОперации,
	                    |	НАЧАЛОПЕРИОДА(Все_Отгрузки.ДокументСсылка.Дата, ДЕНЬ) КАК ДатаДокумента,
	                    |	ВЫБОР
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ОтгрузкаТоваровУслуг
	                    |					И -Все_Отгрузки.Количество > 0
	                    |				ИЛИ Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.РасходныйСкладскойОрдер
	                    |			ТОГДА ""0""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ПоступлениеТоваровУслуг
	                    |				ИЛИ Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ПриходныйСкладскойОрдер
	                    |			ТОГДА ""1""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ВозвратТоваровОтПокупателя
	                    |			ТОГДА ""2""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.СписаниеТоваров
	                    |			ТОГДА ""3""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ВозвратТоваровПоставщику
	                    |			ТОГДА ""4""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ПеремещениеТоваров
	                    |				И Все_Отгрузки.Количество > 0
	                    |			ТОГДА ""6""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ПеремещениеТоваров
	                    |				И Все_Отгрузки.Количество < 0
	                    |			ТОГДА ""5""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ОприходованиеТоваров
	                    |			ТОГДА ""7""
	                    |		КОГДА Все_Отгрузки.ДокументСсылка ССЫЛКА Документ.ОтгрузкаТоваровУслуг
	                    |				И -Все_Отгрузки.Количество < 0
	                    |			ТОГДА ""2""
	                    |		ИНАЧЕ ""-""
	                    |	КОНЕЦ КАК ТипПеремещения,
	                    |	Все_Отгрузки.ТорговыйПредставитель.Код КАК КодТорговогоПредставителя,
	                    |	Все_Отгрузки.ТорговыйПредставитель.Наименование КАК НаименованиеТорговогоПредставителя,
	                    |	ВЫРАЗИТЬ(Все_Отгрузки.Контрагент.НаименованиеПолное КАК СТРОКА(250)) КАК НаименованиеКонтрагента,
	                    |	Все_Отгрузки.Контрагент.Код КАК КодКонтрагента,
	                    |	Все_Отгрузки.Контрагент.ИНН КАК ИНН,
	                    |	""0"" КАК НомерСклада,
	                    |	Все_Отгрузки.ДокументСсылка.Номер КАК НомерДокумента,
	                    |	"""" КАК НомерВходящегоДокумента,
						|	ВЫБОР
						|		КОГДА Все_Отгрузки.СтруктурнаяЕдиницаКонтрагента.КПП = """"
						|			ТОГДА Все_Отгрузки.Контрагент.КПП
						|		ИНАЧЕ Все_Отгрузки.СтруктурнаяЕдиницаКонтрагента.КПП
						|	КОНЕЦ КАК КПП,
	                    |	Все_Отгрузки.Номенклатура.Код КАК КодНоменклатуры,
	                    |	ВЫРАЗИТЬ(Все_Отгрузки.Номенклатура.НаименованиеПолное КАК СТРОКА(250)) КАК НаименованиеНоменклатуры,
	                    |	-Все_Отгрузки.Количество КАК Количество,
	                    |	Все_Отгрузки.Цена КАК Цена,
	                    |	""RUR"" КАК ВалютаДокумента,
	                    |	"""" КАК КодСупервайзера,
	                    |	"""" КАК Супервайзер,
	                    |	"""" КАК ДатаВыпуска,
	                    |	Адреса.Client_Address КАК АдресКонтрагента
	                    |ИЗ
	                    |	ВТ_ВсеОтгрузки КАК Все_Отгрузки
	                    |		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ТорговыеТочкиПокупателей КАК Адреса
	                    |		ПО Все_Отгрузки.СтруктурнаяЕдиницаКонтрагента = Адреса.ТорговаяТочка
	                    |ГДЕ
	                    |	Все_Отгрузки.Период МЕЖДУ &НачалоПериода И &КонецПериода
	                    |
	                    |УПОРЯДОЧИТЬ ПО
	                    |	Все_Отгрузки.Период";
								
									
	РезультатЗапроса = ОбщийЗапрос.Выполнить().Выгрузить();	
	НомерСтроки = 2;
	ПорядковыйНомер = 1;
	ТекстовыйФайл.ДобавитьСтроку("№ п/п"+Таб+"ИД операции"+Таб+"Дата операции"+Таб+"Дата документа"+Таб+"Тип перемещения"+Таб+"Код торгового представителя"+Таб+"Торговый представитель"+Таб+"Наименование клиента"+Таб+"Код клиента"+Таб+"ИНН Клиента"+Таб+"Номер склада"+Таб+"№ документа 1"+Таб+"№ документа 2"+Таб+"№ документа 3"+Таб+"Код ТП"+Таб+"Наименование ТП"+Таб+"Кол-во, в ед. товара"+Таб+"Цена"+Таб+"Валюта операции"+Таб+"Код супервайзера"+Таб+"Супервайзер"+Таб+"Дата выпуска"+Таб+"Адрес клиента"+Таб);
	Для Каждого СтрЗапрос из РезультатЗапроса цикл
		СтрокаДанных = "";
		Если СтрЗапрос.Количество = 0 тогда
			Продолжить;
		КонецЕсли;	
		СтрокаДанных =  СтрокаДанных + Формат(ПорядковыйНомер, "ЧГ=0") +Таб;
		
		НомерКолонкиТЧ = 2;
		Для Каждого Колонка из РезультатЗапроса.Колонки цикл
			ЗначКолонки = СтрЗапрос[Колонка.Имя];
			Если Колонка.Имя = "Количество" тогда
				ЗначКолонки = ?(ЗначКолонки < 0, ЗначКолонки * (-1), ЗначКолонки);
			КонецЕсли;	
			Если ТипЗнч(ЗначКолонки) = Тип("Дата") тогда
				ЗначКолонки = Формат(ЗначКолонки, "ДФ = dd.MM.yyyy");
			КонецЕсли;	
			Если ТипЗнч(ЗначКолонки) = Тип("Число") тогда
				ЗначКолонки = Формат(ЗначКолонки, "ЧГ=0");
			КонецЕсли;	
			СтрокаДанных = СтрокаДанных + СокрЛП(ЗначКолонки) + Таб;
			
			НомерКолонкиТЧ = НомерКолонкиТЧ + 1;
		КонецЦикла;
		НомерСтроки = НомерСтроки + 1;
		ПорядковыйНомер = ПорядковыйНомер + 1;
		ТекстовыйФайл.ДобавитьСтроку(СтрокаДанных);
	КонецЦикла;	
	
КонецПроцедуры	

Процедура ДанныеТретьегоЛиста()
	
	Запрос = Новый Запрос("ВЫБРАТЬ
	                      |	ВложенныйЗапрос.КодНоменклатуры  КАК КодНоменклатуры,
	                      |	ВложенныйЗапрос.НаименованиеНоменклатуры,
	                      |	СУММА(ВложенныйЗапрос.КоличествоНачальныйОстаток) КАК КоличествоНачальныйОстаток,
	                      |	СУММА(ВложенныйЗапрос.КоличествоКонечныйОстаток) КАК КоличествоКонечныйОстаток,
	                      |	ВложенныйЗапрос.НомерСклада,
	                      |	"""" КАК ДатаВыпуска
	                      |ИЗ
	                      |	(ВЫБРАТЬ
	                      |		ЗапасыНаСкладахОстатки.Номенклатура.Код КАК КодНоменклатуры,
	                      |		ВЫРАЗИТЬ(ЗапасыНаСкладахОстатки.Номенклатура.НаименованиеПолное КАК СТРОКА(250)) КАК НаименованиеНоменклатуры,
	                      |		ЗапасыНаСкладахОстатки.КоличествоОстаток КАК КоличествоНачальныйОстаток,
	                      |		0 КАК КоличествоКонечныйОстаток,
	                      |		""0"" КАК НомерСклада
	                      |	ИЗ
	                      |		РегистрНакопления.ЗапасыНаСкладах.Остатки(
	                      |				&Дата1,
	                      |				Номенклатура В ИЕРАРХИИ (&ТекущаяГруппа)
	                      |					И НЕ Склад В (&Магазины)) КАК ЗапасыНаСкладахОстатки
	                      |	
	                      |	ОБЪЕДИНИТЬ ВСЕ
	                      |	
	                      |	ВЫБРАТЬ
	                      |		ЗапасыНаСкладахОстатки.Номенклатура.Код,
	                      |		ВЫРАЗИТЬ(ЗапасыНаСкладахОстатки.Номенклатура.НаименованиеПолное КАК СТРОКА(250)),
	                      |		0,
	                      |		ЗапасыНаСкладахОстатки.КоличествоОстаток,
	                      |		""0""
	                      |	ИЗ
	                      |		РегистрНакопления.ЗапасыНаСкладах.Остатки(
	                      |				&Дата2,
	                      |				Номенклатура В ИЕРАРХИИ (&ТекущаяГруппа)
	                      |					И НЕ Склад В (&Магазины)) КАК ЗапасыНаСкладахОстатки) КАК ВложенныйЗапрос
	                      |
	                      |СГРУППИРОВАТЬ ПО
	                      |	ВложенныйЗапрос.НаименованиеНоменклатуры,
	                      |	ВложенныйЗапрос.НомерСклада,
	                      |	ВложенныйЗапрос.КодНоменклатуры");
	Запрос.УстановитьПараметр("Дата1", ДатаНач);
	Запрос.УстановитьПараметр("Дата2", КонецДня(ДатаКон));
	Запрос.УстановитьПараметр("ТекущаяГруппа", ТекущаяГруппаНоменклатуры);
	Запрос.УстановитьПараметр("Магазины", СкладМагазины);
	
	Остатки = Запрос.Выполнить().Выгрузить();
	
	НомерСтроки = 2;
	ТекстовыйФайл.ДобавитьСтроку("Код ТП"+таб+"Наименование ТП"+Таб+"Остаток на начало, в ед. товара"+Таб+"Остаток на конец, в ед. товара"+Таб+"Номер склада"+Таб+"Дата выпуска"+Таб);
	Для Каждого ОстатокНоменклатуры из Остатки цикл
		СтрокаДанных = "";
		НомерКолонки = 1;
		Для Каждого Колонка из Остатки.Колонки цикл
			ЗначКолонки = ОстатокНоменклатуры[Колонка.Имя];
			Если ТипЗнч(ЗначКолонки) = Тип("Число") тогда
				Если ЗначКолонки = 0 тогда
					ЗначКолонки = "0"
				else
					ЗначКолонки = Формат(ЗначКолонки, "ЧГ=0");
				КонецЕсли;	
			КонецЕсли;	
			СтрокаДанных = СтрокаДанных + СокрЛП(ЗначКолонки) + Таб;
			НомерКолонки = НомерКолонки + 1;
		КонецЦикла;	
		ТекстовыйФайл.ДобавитьСтроку(СтрокаДанных);
		НомерСтроки = НомерСтроки + 1;
	КонецЦикла;	
	
КонецПроцедуры	
	
#КонецОбласти 

#Область РАБОТА_С_ПОЧТОЙ

Функция СоздатьПрофиль()
	
	УчетнаяЗапись = Справочники.УчетныеЗаписиЭлектроннойПочты.НайтиПоКоду("Ц00000019"); 
	Профиль = Новый ИнтернетПочтовыйПрофиль;
	
	Профиль.АдресСервераPOP3 = УчетнаяЗапись.POP3Сервер;
	Профиль.АдресСервераSMTP = УчетнаяЗапись.SMTPСервер;
	Если УчетнаяЗапись.ВремяОжиданияСервера > 0 Тогда
		Профиль.ВремяОжидания = УчетнаяЗапись.ВремяОжиданияСервера;
	КонецЕсли; 
	Профиль.Пароль           = УчетнаяЗапись.Пароль;
	Профиль.Пользователь     = УчетнаяЗапись.Логин;
	Профиль.ПортPOP3         = УчетнаяЗапись.ПортPOP3;
	Профиль.ПортSMTP         = УчетнаяЗапись.ПортSMTP;
	
	Если УчетнаяЗапись.ТребуетсяSMTPАутентификация Тогда
		Профиль.ПарольSMTP       = УчетнаяЗапись.ПарольSMTP;
		Профиль.ПользовательSMTP = УчетнаяЗапись.ЛогинSMTP;
	Иначе
		Профиль.ПарольSMTP       = УчетнаяЗапись.Пароль;
		Профиль.ПользовательSMTP = УчетнаяЗапись.Логин;
	КонецЕсли; 
	
	Возврат Профиль;
	
КонецФункции

Процедура ОтправитьОтчетНаПочту()
	
	ТемаПисьма = "ТД Шкуренко "+Формат(ДатаНач,"ДФ=ddMMyyyy")+"-"+Формат(ДатаКон,"ДФ=ddMMyyyy");					
	
	ПочтовыйПрофиль = СоздатьПрофиль();
	
	Почта = Новый ИнтернетПочта();
	Почта.Подключиться(ПочтовыйПрофиль);
	
	Письмо = Новый ИнтернетПочтовоеСообщение ;
	Письмо.Кодировка = "windows-1251";
	Письмо.Тема = ТемаПисьма;
	Письмо.ИмяОтправителя="ТД Шкуренко";
	Письмо.Отправитель="it@soveren.ru";
	
	МассивПолучателей = ОбщиеФункции.РазложитьСтрокуВМассив(СтруктураПараметров.АдресаПолучателейОтчета, ";");
	
	Для Каждого Получатель Из МассивПолучателей цикл
		
		Письмо.Получатели.Добавить(Получатель);
		
	КонецЦикла;	
		
	Для Сч=0 по СписокФайлов.Количество()-1 цикл
		Письмо.Вложения.Добавить(СписокФайлов[Сч].Значение);
	Конеццикла;
	
	Почта.Послать(Письмо);
	Почта.Отключиться();
	Сообщить("Отправлено", СтатусСообщения.Информация);
	// Удалим из кучи ссылки на объекты "ИнтернетПочтовоеСообщение" и "ИнтернетПочта";
	Почта = Неопределено; Письмо = Неопределено;
	// Чистим каталог временных файлов
	Для Сч=0 по СписокФайлов.Количество()-1 цикл
		УдалитьФайлы(СписокФайлов[Сч].Значение);
	Конеццикла;
	
	
КонецПроцедуры	

#КонецОбласти 

Процедура ВыгрузитьДанные(СписокВнешнихСистем) экспорт
	
	СписокФайлов = Новый СписокЗначений;
	
	Если Не ПроизвольныйИнтервал тогда
		
		Попытка
		
			УстановитьНастройкиПериода();
		
		Исключение
		 	#Если Клиент Тогда
				Предупреждение(ИнформацияОбОшибке().Описание);
			#КонецЕсли 
		КонецПопытки;
		
	КонецЕсли;	
	
	Для Каждого ЭлементСписка Из СписокВнешнихСистем цикл
		
		Для Каждого СтрокаТабЧасти из СтруктураПараметров.ГруппыНоменклатуры цикл	
			
			ТекущаяГруппаНоменклатуры = СтрокаТабЧасти.Группа;
			
			ОбщийЗапрос();
			Для Сч = 1 по 3 цикл
				ТекстовыйФайл = Новый ТекстовыйДокумент;
				//Лист = Книга.Worksheets(Сч);
				Если Сч = 1 тогда
					ДанныеПервогоЛиста();
				ИначеЕсли Сч = 2 тогда 
					ДанныеВторогоЛиста();
				Иначе
					ДанныеТретьегоЛиста();
				КонецЕсли;	
				
				ПолныйПуть = КаталогВременныхФайлов()+"ТД Шкуренко "+Формат(ДатаНач,"ДФ=ddMMyyyy")+"-"+Формат(ДатаКон,"ДФ=ddMMyyyy")+"_"+Сч+".csv";
				ТекстовыйФайл.Записать(ПолныйПуть, "cp1251");    
				СписокФайлов.Добавить(ПолныйПуть);
				
			КонецЦикла;
			
			Попытка
				
				ОтправитьОтчетНаПочту()
				
			Исключение
				Сообщить("Произошла ошибка при отправке отчета на почту!
				|Ошибка: "+ ИнформацияОбОшибке().Описание);	
			КонецПопытки;
		КонецЦикла;	
		
	КонецЦикла;
	
	
КонецПроцедуры	

Таб = Символы.Таб;

СкладМагазины = Новый СписокЗначений;
Выборка = Справочники.Склады.Выбрать(Справочники.Склады.НайтиПоКоду("Ц00053"));
Пока Выборка.Следующий() цикл
	СкладМагазины.Добавить(Выборка.Ссылка)	;
КонецЦикла;




