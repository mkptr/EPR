﻿
Функция ПодключитьсяКбазе() Экспорт
	
	//ПараметрыПодключения = "Srvr=""aps-1c:2341"";Ref=""1CSC"";Usr=""ESD"";Pwd=""webs2689"";";
	
	ПараметрыПодключения = "Srvr=""sv08:2341"";Ref=""DEV01"";Usr=""ESD"";Pwd=""webs2689"";";
	//ПараметрыПодключения = "Srvr=""sv08:2341"";Ref=""DEV03"";Usr=""ESD"";Pwd=""webs2689"";";
	
	V82COMConnector= Новый COMОбъект("V82.COMConnector");
	Попытка
		Возврат V82COMConnector.Connect(ПараметрыПодключения);
	Исключение
		//Сообщить(ОписаниеОшибки());
		ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка подключения к базе УПП.",
			УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат Неопределено;
	КонецПопытки;
		
КонецФункции


//////// устарели

Функция СоздатьНоменклатуруИзДругойБазы(Соединение, Артикул, ЭтоНабор = Ложь)
	
	Номенклатура = Неопределено;
	
	Если ЗначениеЗаполнено(Артикул) Тогда
	
		СсылкаНаОбъект = Соединение.Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", Артикул);
	
		Если СсылкаНаОбъект = Неопределено Тогда 
			Сообщить("Не найдена номенклатура в другой базе.");
			Возврат Неопределено;
		КонецЕсли;
		
		//УИД = Соединение.String(СсылкаНаОбъект.УникальныйИдентификатор());
		Номенклатура = Справочники.Номенклатура.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
		
		НоменклатураОбъект = Справочники.Номенклатура.СоздатьЭлемент();
		НоменклатураОбъект.УстановитьСсылкуНового(Номенклатура);
		
		ЗаполнитьЗначенияСвойств(НоменклатураОбъект, СсылкаНаОбъект, "Код,Наименование,Артикул,НаименованиеПолное");
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	УпаковкиЕдиницыИзмерения.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.УпаковкиЕдиницыИзмерения КАК УпаковкиЕдиницыИзмерения
			|ГДЕ
			|	УпаковкиЕдиницыИзмерения.Код = &Код
			|	И УпаковкиЕдиницыИзмерения.Владелец = ЗНАЧЕНИЕ(Справочник.НаборыУпаковок.БазовыеЕдиницыИзмерения)";
		Запрос.УстановитьПараметр("Код", СсылкаНаОбъект.БазоваяЕдиницаИзмерения.Код);
		ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			ЕдиницаИзмерения = ВыборкаДетальныеЗаписи.Ссылка;
		Иначе
			ЕдиницаИзмерения = Константы.ЕдиницаИзмеренияКоличестваШтук.Получить();
		КонецЕсли;
		НоменклатураОбъект.ЕдиницаИзмерения = ЕдиницаИзмерения;
		НоменклатураОбъект.ВариантОформленияПродажи = Перечисления.ВариантыОформленияПродажи.РеализацияТоваровУслуг;
		Если ЭтоНабор Тогда
			НоменклатураОбъект.ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Комплект кодов игр");
		Иначе
			НоменклатураОбъект.ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Игры");
		КонецЕсли;
		НоменклатураОбъект.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.НеИспользовать;
		НоменклатураОбъект.Качество = Перечисления.ГрадацииКачества.Новый;
		НоменклатураОбъект.СтавкаНДС = Перечисления.СтавкиНДС[Соединение.XMLСтрока(СсылкаНаОбъект.СтавкаНДС)];
		НоменклатураОбъект.ТипНоменклатуры = НоменклатураОбъект.ВидНоменклатуры.ТипНоменклатуры;
		НоменклатураОбъект.ЕдиницаДляОтчетов = ЕдиницаИзмерения;
		НоменклатураОбъект.КоэффициентЕдиницыДляОтчетов = 1;
		НоменклатураОбъект.ОсобенностьУчета = Перечисления.ОсобенностиУчетаНоменклатуры.БезОсобенностейУчета;
		
		НоменклатураОбъект.Записать();
		
	КонецЕсли;

	Возврат Номенклатура;
	
КонецФункции

Функция СоздатьСоглашениеИзДругойБазы(Соединение, Аккаунт)
	
	Соглашение = Неопределено;
	
	Если ЗначениеЗаполнено(Аккаунт) Тогда
	
		СсылкаНаОбъект = Соединение.Справочники.ДоговорыКонтрагентов.НайтиПоКоду(Аккаунт);
	
		Если СсылкаНаОбъект = Неопределено Тогда 
			Сообщить("Не найден аккаунт в другой базе.");
			Возврат Неопределено;
		КонецЕсли;
		
		Соглашение = Справочники.СоглашенияСКлиентами.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
		
		СоглашениеОбъект = Справочники.СоглашенияСКлиентами.СоздатьЭлемент();
		СоглашениеОбъект.УстановитьСсылкуНового(Соглашение);
		
		СоглашениеОбъект.Номер = Аккаунт;
		СоглашениеОбъект.Наименование = СсылкаНаОбъект.Наименование;
		СоглашениеОбъект.Валюта = Справочники.Валюты.НайтиПоКоду(СсылкаНаОбъект.ВалютаВзаиморасчетов.Code);
		СоглашениеОбъект.Организация = ПолучитьОрганизацию(Соединение, СсылкаНаОбъект.Организация);
		СоглашениеОбъект.Контрагент = ПолучитьКонтрагента(Соединение, СсылкаНаОбъект.Владелец);
		СоглашениеОбъект.Партнер = ПолучитьПартнера(Соединение, СсылкаНаОбъект.Владелец.ГоловнойКонтрагент);
		СоглашениеОбъект.ВидЦен = ПолучитьВидЦен(Соединение, СсылкаНаОбъект.ТипЦен);
		СоглашениеОбъект.ЦенаВключаетНДС = СоглашениеОбъект.ВидЦен.ЦенаВключаетНДС;
		СоглашениеОбъект.Склад = ПолучитьСклад(Соединение, СсылкаНаОбъект.СкладПоУмолчанию);
		СоглашениеОбъект.Согласован = Истина;
		//СоглашениеОбъект.Статус = ?(СсылкаНаОбъект.Активный, Перечисления.СтатусыСоглашенийСКлиентами.Действует, Перечисления.СтатусыСоглашенийСКлиентами.Закрыт);
		СоглашениеОбъект.Статус = Перечисления.СтатусыСоглашенийСКлиентами.Действует; // если статус "Не действует", не создается реализация (ошибка заполнения на основании соглашения)
		СоглашениеОбъект.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
		СоглашениеОбъект.ПорядокОплаты = Перечисления.ПорядокОплатыПоСоглашениям.РасчетыВРубляхОплатаВРублях;
		СоглашениеОбъект.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоДоговорамКонтрагентов;
		СоглашениеОбъект.ВалютаВзаиморасчетов = СоглашениеОбъект.Валюта;
		
		СоглашениеОбъект.Записать();
		
	КонецЕсли;

	Возврат Соглашение;
	
КонецФункции

Функция ПолучитьЦенуИзДругойБазы(Соединение, Дата, Аккаунт, Артикул)
	
	Результат = Новый Структура();
	
	Запрос = Соединение.NewObject("Запрос");
	Запрос.Текст = 
		"
		|ВЫБРАТЬ
		|	""ЦенаПродажи"" КАК Тип,
		|	Т.ТипЦен КАК ТипЦен
		|ПОМЕСТИТЬ ТипыЦен
		|ИЗ
		|	(ВЫБРАТЬ ПЕРВЫЕ 1
		|		Т.ТипЦен КАК ТипЦен
		|	ИЗ
		|		(ВЫБРАТЬ
		|			1 КАК Приоритет,
		|			Т.ТипЦен КАК ТипЦен
		|		ИЗ
		|			(ВЫБРАТЬ ПЕРВЫЕ 1
		|				ТипыЦен.Ссылка КАК ТипЦен
		|			ИЗ
		|				Справочник.ДоговорыКонтрагентов.Изменения КАК Договоры
		|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|					ПО Договоры.НовоеЗначение = ТипыЦен.Наименование
		|			ГДЕ
		|				Договоры.ЧтоИзменил = ""Тип цен""
		|				И Договоры.Ссылка.Код = &Аккаунт
		|				И Договоры.ДатаИзменения <= &Дата
		|			
		|			УПОРЯДОЧИТЬ ПО
		|				Договоры.ДатаИзменения УБЫВ) КАК Т
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			2,
		|			Договоры.ТипЦен
		|		ИЗ
		|			Справочник.ДоговорыКонтрагентов КАК Договоры
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|				ПО Договоры.ТипЦен = ТипыЦен.Ссылка
		|		ГДЕ
		|			Договоры.Код = &Аккаунт
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			3,
		|			ЗНАЧЕНИЕ(Справочник.ТипыЦенНоменклатуры.RRP)) КАК Т
		|	
		|	УПОРЯДОЧИТЬ ПО
		|		Т.Приоритет) КАК Т
		|
		|ОБЪЕДИНИТЬ ВСЕ
		|
		|ВЫБРАТЬ
		|	""Себестоимость"",
		|	Т.ТипЦен
		|ИЗ
		|	(ВЫБРАТЬ ПЕРВЫЕ 1
		|		Т.ТипЦен КАК ТипЦен
		|	ИЗ
		|		(ВЫБРАТЬ
		|			1 КАК Приоритет,
		|			Т.ТипЦен КАК ТипЦен
		|		ИЗ
		|			(ВЫБРАТЬ ПЕРВЫЕ 1
		|				ТипыЦен.Ссылка КАК ТипЦен
		|			ИЗ
		|				Справочник.ДоговорыКонтрагентов.Изменения КАК Договоры
		|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|					ПО Договоры.НовоеЗначение = ТипыЦен.Наименование
		|			ГДЕ
		|				Договоры.ЧтоИзменил = ""Тип цен себестоимости""
		|				И Договоры.Ссылка.Код = &Аккаунт
		|				И Договоры.ДатаИзменения <= &Дата
		|			
		|			УПОРЯДОЧИТЬ ПО
		|				Договоры.ДатаИзменения УБЫВ) КАК Т
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			2,
		|			Договоры.ТипЦенСебестоимости
		|		ИЗ
		|			Справочник.ДоговорыКонтрагентов КАК Договоры
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|				ПО Договоры.ТипЦенСебестоимости = ТипыЦен.Ссылка
		|		ГДЕ
		|			Договоры.Код = &Аккаунт
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			3,
		|			ЗНАЧЕНИЕ(Справочник.ТипыЦенНоменклатуры.СебестоимостьRUB)) КАК Т
		|	
		|	УПОРЯДОЧИТЬ ПО
		|		Т.Приоритет) КАК Т
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	ТипыЦен.Тип,
		//|	ЦеныНоменклатурыСрезПоследних.ТипЦен,
		//|	ЦеныНоменклатурыСрезПоследних.Номенклатура,
		|	ЦеныНоменклатурыСрезПоследних.Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|			&Дата,
		|			ТипЦен В
		|					(ВЫБРАТЬ
		|						ТипыЦен.ТипЦен
		|					ИЗ
		|						ТипыЦен КАК ТипыЦен)
		|				И Номенклатура.Артикул = &Артикул) КАК ЦеныНоменклатурыСрезПоследних
		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ ТипыЦен КАК ТипыЦен
		|		ПО ЦеныНоменклатурыСрезПоследних.ТипЦен = ТипыЦен.ТипЦен
		|";
	
	Запрос.УстановитьПараметр("Аккаунт", Аккаунт);
	Запрос.УстановитьПараметр("Артикул", Артикул);
	Запрос.УстановитьПараметр("Дата", КонецДня(Дата));
	
	Выборка = Запрос.Выполнить().Выбрать();
	Пока Выборка.Следующий() Цикл
		Результат.Вставить(Выборка.Тип, Выборка.Цена);
	КонецЦикла;	
	
	Возврат Результат;
	
КонецФункции

Процедура ОбработатьТранзакцииESD(Параметры, АдресРезультата) Экспорт
	
	ОбработатьТранзакции(Параметры);
	
	Результат = Истина;
	ПоместитьВоВременноеХранилище(Результат, АдресРезультата);
	
КонецПроцедуры

Процедура ОбработатьТранзакцииESDПараллельно(Дата) Экспорт
	
	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("ДатаНачала", Дата);
	ПараметрыПроцедуры.Вставить("ДатаОкончания", Дата);
	
	ОбработатьТранзакции(ПараметрыПроцедуры);
	
КонецПроцедуры

Процедура ОбработатьТранзакции(Параметры) 
	
	Соединение = Неопределено;
	
	Количество = 0;
	Если Параметры.Свойство("КоличествоТранзакций") Тогда
		Количество = Параметры.КоличествоТранзакций;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ " + ?(Количество > 0, "ПЕРВЫЕ "+Строка(Формат(Количество, "ЧГ=")), "") + "
		|	Т.Date КАК Date,
		|	Т.AgreementScId КАК AgreementScId,
		|	Т.NomenclatureScId КАК NomenclatureScId,
		|	Т.ServerTxId КАК ServerTxId,
		|	Т.TxRef КАК TxRef,
		|	Т.TransactionKind КАК TransactionKind,
		|	Т.Manufacture КАК Manufacture,
		|	Т.SerialId КАК SerialId,
		|	Т.SerialSetScId КАК SerialSetScId,
		|	Т.Price КАК Price,
		|	Т.Номенклатура КАК Номенклатура,
		|	Т.Комплектующая КАК Комплектующая,
		|	Т.Серия КАК Серия,
		|	Т.Соглашение КАК Соглашение
		|ИЗ
		|	РегистрСведений.ТранзакцииESD КАК Т
		|ГДЕ
		|	(Т.Номенклатура = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
		|	ИЛИ Т.Комплектующая = ЗНАЧЕНИЕ(Справочник.Номенклатура.ПустаяСсылка)
		|	ИЛИ Т.Серия = ЗНАЧЕНИЕ(Справочник.СерииНоменклатуры.ПустаяСсылка)
		|	ИЛИ Т.Соглашение = ЗНАЧЕНИЕ(Справочник.СоглашенияСКлиентами.ПустаяСсылка)
		|	ИЛИ Т.Price = 0
		|	ИЛИ (Т.Себестоимость = 0 И Т.Manufacture И Т.TransactionKind = ""Sale""))
		|	И Т.Date >= &ДатаНачала
		|	И Т.Date <= &ДатаОкончания
		|";
	
	Запрос.УстановитьПараметр("ДатаНачала", Параметры.ДатаНачала);
	Запрос.УстановитьПараметр("ДатаОкончания", Параметры.ДатаОкончания);
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		Попытка
			
			Если Соединение = Неопределено Тогда
				Соединение = ПодключитьсяКбазе();
				Если Соединение = Неопределено Тогда 
					Сообщить("Ошибка установки соединения.");
					Возврат;
				КонецЕсли;
			КонецЕсли;
			
			Номенклатура = ВыборкаДетальныеЗаписи.Номенклатура;
			Если НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Номенклатура) Тогда
				Номенклатура = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", СокрЛП(ВыборкаДетальныеЗаписи.NomenclatureScId));
				Если НЕ ЗначениеЗаполнено(Номенклатура) Тогда
					Номенклатура = СоздатьНоменклатуруИзДругойБазы(Соединение, ВыборкаДетальныеЗаписи.NomenclatureScId, ВыборкаДетальныеЗаписи.Manufacture);
					Если НЕ ЗначениеЗаполнено(Номенклатура) Тогда
						Сообщить("Ошибка создания Номенклатуры");
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
			Комплектующая = ВыборкаДетальныеЗаписи.Комплектующая;
			//Если ВыборкаДетальныеЗаписи.SerialSetScId = ВыборкаДетальныеЗаписи.NomenclatureScId Тогда  // встречаются ституации, когда нет комплекта, а SerialSetScId <> NomenclatureScId
			Если ВыборкаДетальныеЗаписи.Manufacture Тогда
				Комплектующая = Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", СокрЛП(ВыборкаДетальныеЗаписи.SerialSetScId));
				Если НЕ ЗначениеЗаполнено(Комплектующая) Тогда
					Комплектующая = СоздатьНоменклатуруИзДругойБазы(Соединение, ВыборкаДетальныеЗаписи.SerialSetScId);
					Если НЕ ЗначениеЗаполнено(Комплектующая) Тогда
						Сообщить("Ошибка создания Номенклатуры");
					КонецЕсли;
				КонецЕсли;
			Иначе
				Комплектующая = Номенклатура;
			КонецЕсли;
			
			Серия = ВыборкаДетальныеЗаписи.Серия;
			Если НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Серия) Тогда
				Серия = Справочники.СерииНоменклатуры.НайтиПоРеквизиту("Номер", СокрЛП(ВыборкаДетальныеЗаписи.SerialId));
				Если НЕ ЗначениеЗаполнено(Серия) Тогда
					СерияОбъект = Справочники.СерииНоменклатуры.СоздатьЭлемент();
					СерияОбъект.Номер = СокрЛП(ВыборкаДетальныеЗаписи.SerialId);
					СерияОбъект.ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Игры");
					СерияОбъект.Записать();
					Серия = СерияОбъект.Ссылка;
					Если НЕ ЗначениеЗаполнено(Серия) Тогда
						Сообщить("Ошибка создания Серии");
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
			Соглашение = ВыборкаДетальныеЗаписи.Соглашение;
			Если НЕ ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.Соглашение) Тогда
				Соглашение = Справочники.СоглашенияСКлиентами.НайтиПоРеквизиту("Номер", СокрЛП(ВыборкаДетальныеЗаписи.AgreementScId));
				Если НЕ ЗначениеЗаполнено(Соглашение) Тогда
					Соглашение = СоздатьСоглашениеИзДругойБазы(Соединение, ВыборкаДетальныеЗаписи.AgreementScId);
					Если НЕ ЗначениеЗаполнено(Соглашение) Тогда
						Сообщить("Ошибка создания Соглашения");
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
			
			Цена = 0; Себестоимость = 0;
			ЦеныNomenclatureScId = ПолучитьЦенуИзДругойБазы(Соединение, ВыборкаДетальныеЗаписи.Date, ВыборкаДетальныеЗаписи.AgreementScId, ВыборкаДетальныеЗаписи.NomenclatureScId);
			Если ЦеныNomenclatureScId.Свойство("ЦенаПродажи") Тогда
				Цена = ЦеныNomenclatureScId.ЦенаПродажи;
			КонецЕсли;
			//Если ВыборкаДетальныеЗаписи.SerialSetScId = ВыборкаДетальныеЗаписи.NomenclatureScId Тогда
			Если ВыборкаДетальныеЗаписи.Manufacture Тогда
				ЦеныSerialSetScId = ПолучитьЦенуИзДругойБазы(Соединение, ВыборкаДетальныеЗаписи.Date, ВыборкаДетальныеЗаписи.AgreementScId, ВыборкаДетальныеЗаписи.SerialSetScId);
				Если ЦеныSerialSetScId.Свойство("Себестоимость") Тогда
					Себестоимость = ЦеныSerialSetScId.Себестоимость;
				КонецЕсли;
			Иначе
				Если ЦеныNomenclatureScId.Свойство("Себестоимость") Тогда
					Себестоимость = ЦеныNomenclatureScId.Себестоимость;
				КонецЕсли;
			КонецЕсли;
		
		Исключение
			
			Если ВыборкаДетальныеЗаписи.SerialSetScId = "123" Тогда
				ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Запись SerialSetScId = 123",
					УровеньЖурналаРегистрации.Предупреждение,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			Иначе		
				ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка идентификации объекта",
					УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				Продолжить;
			КонецЕсли;
			
		КонецПопытки;
			
		НаборЗаписей = РегистрыСведений.ТранзакцииESD1.СоздатьНаборЗаписей();
		
		НаборЗаписей.Отбор.Date.Установить(ВыборкаДетальныеЗаписи.Date);
		НаборЗаписей.Отбор.AgreementScId.Установить(ВыборкаДетальныеЗаписи.AgreementScId);
		НаборЗаписей.Отбор.NomenclatureScId.Установить(ВыборкаДетальныеЗаписи.NomenclatureScId);
		НаборЗаписей.Отбор.ServerTxId.Установить(ВыборкаДетальныеЗаписи.ServerTxId);
		НаборЗаписей.Отбор.Manufacture.Установить(ВыборкаДетальныеЗаписи.Manufacture);
		НаборЗаписей.Отбор.TransactionKind.Установить(ВыборкаДетальныеЗаписи.TransactionKind);
		НаборЗаписей.Отбор.TxRef.Установить(ВыборкаДетальныеЗаписи.TxRef);
		НаборЗаписей.Отбор.SerialId.Установить(ВыборкаДетальныеЗаписи.SerialId);
		НаборЗаписей.Отбор.SerialSetScId.Установить(ВыборкаДетальныеЗаписи.SerialSetScId);
	
		НаборЗаписей.Прочитать();
		
		Если ВыборкаДетальныеЗаписи.SerialSetScId = "123" Тогда
			НаборЗаписей.Очистить();	
		КонецЕсли;
		
		Для Каждого Запись Из НаборЗаписей Цикл
			Запись.Номенклатура = Номенклатура;
			Запись.Комплектующая = Комплектующая;
			Запись.Серия = Серия;
			Запись.Соглашение = Соглашение;
			Запись.Price = Цена;
			Запись.Себестоимость = Себестоимость;
		КонецЦикла;		
		
		Попытка
			НаборЗаписей.Записать();
		Исключение
			ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка записи регистра",
				УровеньЖурналаРегистрации.Ошибка, Метаданные.РегистрыСведений.ТранзакцииESD1,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

Процедура ЗагрузкаЦенПоТранзакциям_олд() Экспорт
	
	Соединение = ПодключитьсяКбазе();
	Если Соединение = Неопределено Тогда 
		Сообщить("Ошибка установки соединения.");
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 10000
		|	Т.ServerTxId КАК ServerTxId
		|ИЗ
		|	РегистрСведений.ТранзакцииESD КАК Т
		|ГДЕ
		|	НЕ Т.Обработано
		|
		|УПОРЯДОЧИТЬ ПО
		|	Т.Date УБЫВ";
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	КоличествоЗаписейВТранзакции = 100;
		
	НачатьТранзакцию();
	НомерЗаписи = 0;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НомерЗаписи = НомерЗаписи + 1;
		Если НомерЗаписи >= КоличествоЗаписейВТранзакции Тогда
			ЗафиксироватьТранзакцию();
			НомерЗаписи = 0;
			НачатьТранзакцию();
		КонецЕсли;
		
		НаборЗаписей = РегистрыСведений.ТранзакцииESD.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ServerTxId.Установить(ВыборкаДетальныеЗаписи.ServerTxId);
		НаборЗаписей.Прочитать();
		
		Отбор = Соединение.NewObject("Структура");
		Отбор.Вставить("ТипЦен", Соединение.Справочники.ДоговорыКонтрагентов.НайтиПоКоду(НаборЗаписей[0].AgreementScId).ТипЦен);
		Отбор.Вставить("Номенклатура", Соединение.Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", НаборЗаписей[0].NomenclatureScId));
		Отбор.Вставить("ХарактеристикаНоменклатуры", Соединение.Справочники.ХарактеристикиНоменклатуры.ПустаяСсылка());
		
		Результат = Соединение.РегистрыСведений.ЦеныНоменклатуры.ПолучитьПоследнее(КонецДня(НаборЗаписей[0].Date), Отбор);
		
		Для Каждого Запись Из НаборЗаписей Цикл
			Запись.Price = Результат.Цена;
			Запись.Обработано = Истина;
		КонецЦикла;		
		
		НаборЗаписей.Записать();
		
	КонецЦикла;
		
	Если ТранзакцияАктивна() Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;
	
КонецПроцедуры

Процедура ЗагрузкаЦенПоТранзакциям_COM() Экспорт
	
	Соединение = ПодключитьсяКбазе();
	Если Соединение = Неопределено Тогда 
		Сообщить("Ошибка установки соединения.");
		Возврат;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 40000
		|	Т.ServerTxId КАК ServerTxId
		|ИЗ
		|	РегистрСведений.ТранзакцииESD КАК Т
		|ГДЕ
		|	НЕ Т.Обработано
		|	И Т.TxRef = 0
		|	И Т.Date < &Дата
		|
		|УПОРЯДОЧИТЬ ПО
		|	Т.Date";
	
	Запрос.УстановитьПараметр("Дата", НачалоМесяца(ТекущаяДата()));
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	КоличествоЗаписейВТранзакции = 500;
		
	НачатьТранзакцию();
	НомерЗаписи = 0;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НомерЗаписи = НомерЗаписи + 1;
		Если НомерЗаписи >= КоличествоЗаписейВТранзакции Тогда
			ЗафиксироватьТранзакцию();
			НомерЗаписи = 0;
			НачатьТранзакцию();
		КонецЕсли;
		
		НаборЗаписей = РегистрыСведений.ТранзакцииESD.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ServerTxId.Установить(ВыборкаДетальныеЗаписи.ServerTxId);
		НаборЗаписей.Прочитать();
		
		ЗапросСОМ = Соединение.NewObject("Запрос");
		ЗапросСОМ.Текст = 
		"
		|ВЫБРАТЬ
		//|	ЦеныНоменклатурыСрезПоследних.ТипЦен,
		//|	ЦеныНоменклатурыСрезПоследних.Номенклатура,
		|	ЦеныНоменклатурыСрезПоследних.Цена
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатуры.СрезПоследних(
		|			&Дата,
		|			ТипЦен В
		|					(ВЫБРАТЬ ПЕРВЫЕ 1
		|		Т.ТипЦен КАК ТипЦен
		|	ИЗ
		|		(ВЫБРАТЬ
		|			1 КАК Приоритет,
		|			Т.ТипЦен КАК ТипЦен
		|		ИЗ
		|			(ВЫБРАТЬ ПЕРВЫЕ 1
		|				ТипыЦен.Ссылка КАК ТипЦен
		|			ИЗ
		|				Справочник.ДоговорыКонтрагентов.Изменения КАК Договоры
		|					ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|					ПО Договоры.НовоеЗначение = ТипыЦен.Наименование
		|			ГДЕ
		|				Договоры.ЧтоИзменил = ""Тип цен""
		|				И Договоры.Ссылка.Код = &Аккаунт
		|				И Договоры.ДатаИзменения <= &Дата
		|			
		|			УПОРЯДОЧИТЬ ПО
		|				Договоры.ДатаИзменения УБЫВ) КАК Т
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			2,
		|			Договоры.ТипЦен
		|		ИЗ
		|			Справочник.ДоговорыКонтрагентов КАК Договоры
		|				ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.ТипыЦенНоменклатуры КАК ТипыЦен
		|				ПО Договоры.ТипЦен = ТипыЦен.Ссылка
		|		ГДЕ
		|			Договоры.Код = &Аккаунт
		|		
		|		ОБЪЕДИНИТЬ ВСЕ
		|		
		|		ВЫБРАТЬ
		|			3,
		|			ЗНАЧЕНИЕ(Справочник.ТипыЦенНоменклатуры.RRP)) КАК Т
		|	
		|	УПОРЯДОЧИТЬ ПО
		|		Т.Приоритет)
		|				И Номенклатура.Артикул = &Артикул) КАК ЦеныНоменклатурыСрезПоследних
		|";
		ЗапросСОМ.УстановитьПараметр("Аккаунт", НаборЗаписей[0].AgreementScId);
		ЗапросСОМ.УстановитьПараметр("Артикул", НаборЗаписей[0].NomenclatureScId);
		ЗапросСОМ.УстановитьПараметр("Дата", КонецДня(НаборЗаписей[0].Date));
		
		Выборка = ЗапросСОМ.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			НаборЗаписей[0].Price = Выборка.Цена;
		КонецЕсли;	
		НаборЗаписей[0].Обработано = Истина;
		
		НаборЗаписей.Записать();
		
	КонецЦикла;
		
	Если ТранзакцияАктивна() Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;
	
	
	////////////////////////////////////////////////////////////////////////////////////////////
	//Обработка возвратов
	///////////////////////////////////////////////////////////////////////////////////////////
	
	КоличествоЗаписейВТранзакции = 100;
		
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1000
	//|	Возвраты.Date КАК ДатаВозврата, 
	//|	Продажи.Date КАК ДатаПродажи,
	//|	Возвраты.AgreementScId КАК AgreementScId,
	//|	Возвраты.NomenclatureScId КАК NomenclatureScId,
	|	Возвраты.ServerTxId КАК ServerTxId,
	//|	Возвраты.TxRef КАК TxRef,
	|	ЕСТЬNULL(Продажи.Price, 0) КАК Price
	//|	Возвраты.Price КАК ЦенаВозврата,
	//|	Продажи.Обработано КАК Обработано
	|ИЗ
	|	РегистрСведений.ТранзакцииESD КАК Возвраты
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.ТранзакцииESD КАК Продажи
	|		ПО Возвраты.TxRef = Продажи.ServerTxId
	|ГДЕ
	|	НЕ Возвраты.TxRef = 0
	|	И НЕ Возвраты.Обработано
	|	И Продажи.Обработано
	|	И Возвраты.Date < &Дата
	|
	|УПОРЯДОЧИТЬ ПО
	|	Возвраты.Date";
	
	Запрос.УстановитьПараметр("Дата", НачалоМесяца(ТекущаяДата()));
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	НачатьТранзакцию();
	НомерЗаписи = 0;
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		НомерЗаписи = НомерЗаписи + 1;
		Если НомерЗаписи >= КоличествоЗаписейВТранзакции Тогда
			ЗафиксироватьТранзакцию();
			НомерЗаписи = 0;
			НачатьТранзакцию();
		КонецЕсли;
		
		НаборЗаписей = РегистрыСведений.ТранзакцииESD.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ServerTxId.Установить(ВыборкаДетальныеЗаписи.ServerTxId);
		НаборЗаписей.Прочитать();
		
		НаборЗаписей[0].Price = ВыборкаДетальныеЗаписи.Price;
		НаборЗаписей[0].Обработано = Истина;
		
		НаборЗаписей.Записать();
		
	КонецЦикла;
		
	Если ТранзакцияАктивна() Тогда
		ЗафиксироватьТранзакцию();
	КонецЕсли;
	
КонецПроцедуры

//////////////////////




Функция ПолучитьСклад(Соединение, СсылкаНаОбъект)
	
	Склад = Справочники.Склады.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
	
	Если Склад <> Справочники.Склады.ПустаяСсылка() И Склад.ПолучитьОбъект() = Неопределено Тогда
	
		СкладОбъект = Справочники.Склады.СоздатьЭлемент();
		СкладОбъект.УстановитьСсылкуНового(Склад);
		
		СкладОбъект.Наименование = СсылкаНаОбъект.Наименование;
		
		СкладОбъект.Записать();
		
	КонецЕсли;

	Возврат Склад;
	
КонецФункции

Функция ПолучитьВидЦен(Соединение, СсылкаНаОбъект)
	
	ВидЦен = Справочники.ВидыЦен.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
	
	Если ВидЦен <> Справочники.ВидыЦен.ПустаяСсылка() И ВидЦен.ПолучитьОбъект() = Неопределено Тогда
	
		ВидЦенОбъект = Справочники.ВидыЦен.СоздатьЭлемент();
		ВидЦенОбъект.УстановитьСсылкуНового(ВидЦен);
		
		ВидЦенОбъект.Наименование = СсылкаНаОбъект.Наименование;
		ВидЦенОбъект.ВалютаЦены = Справочники.Валюты.НайтиПоКоду(СсылкаНаОбъект.ВалютаЦены.Code);
		ВидЦенОбъект.ЦенаВключаетНДС = СсылкаНаОбъект.ЦенаВключаетНДС;
		ВидЦенОбъект.ИспользоватьПриПродаже = Истина;
		ВидЦенОбъект.СпособЗаданияЦены = Перечисления.СпособыЗаданияЦен.Вручную;
		ВидЦенОбъект.Статус = ?(СсылкаНаОбъект.Активный, Перечисления.СтатусыДействияВидовЦен.Действует, Перечисления.СтатусыДействияВидовЦен.НеДействует);
		
		ВидЦенОбъект.Записать();
		
	КонецЕсли;

	Возврат ВидЦен;
	
КонецФункции

Функция ПолучитьПартнера(Соединение, СсылкаНаОбъект)
	
	Партнер = Справочники.Партнеры.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
	
	Если Партнер <> Справочники.Партнеры.ПустаяСсылка() И Партнер.ПолучитьОбъект() = Неопределено Тогда
	
		ПартнерОбъект = Справочники.Партнеры.СоздатьЭлемент();
		ПартнерОбъект.УстановитьСсылкуНового(Партнер);
		
		ПартнерОбъект.Код = СсылкаНаОбъект.Код;
		ПартнерОбъект.Наименование = СсылкаНаОбъект.Наименование;
		ПартнерОбъект.НаименованиеПолное = СсылкаНаОбъект.НаименованиеПолное;
		ПартнерОбъект.Клиент = СсылкаНаОбъект.Покупатель;
		ПартнерОбъект.Поставщик = СсылкаНаОбъект.Поставщик;
		ПартнерОбъект.ЮрФизЛицо = Перечисления.КомпанияЧастноеЛицо.Компания;
		
		ПартнерОбъект.Записать();
		
	КонецЕсли;

	Возврат Партнер;
	
КонецФункции

Функция ПолучитьКонтрагента(Соединение, СсылкаНаОбъект)
	
	Контрагент = Справочники.Контрагенты.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
	
	Если Контрагент <> Справочники.Контрагенты.ПустаяСсылка() И Контрагент.ПолучитьОбъект() = Неопределено Тогда
	
		КонтрагентОбъект = Справочники.Контрагенты.СоздатьЭлемент();
		КонтрагентОбъект.УстановитьСсылкуНового(Контрагент);
		
		КонтрагентОбъект.Наименование = СсылкаНаОбъект.Наименование;
		КонтрагентОбъект.ГоловнойКонтрагент = Контрагент;
		КонтрагентОбъект.НаименованиеПолное = СсылкаНаОбъект.НаименованиеПолное;
		КонтрагентОбъект.Партнер = ПолучитьПартнера(Соединение, СсылкаНаОбъект.ГоловнойКонтрагент);
		КонтрагентОбъект.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо;
		КонтрагентОбъект.ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		КонтрагентОбъект.СтранаРегистрации = Справочники.СтраныМира.Россия;
		
		КонтрагентОбъект.Записать();
		
	КонецЕсли;

	Возврат Контрагент;
	
КонецФункции

Функция ПолучитьОрганизацию(Соединение, СсылкаНаОбъект)
	
	Организация = Справочники.Организации.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
	
	Если Организация <> Справочники.Организации.ПустаяСсылка() И Организация.ПолучитьОбъект() = Неопределено Тогда
	
		ОрганизацияОбъект = Справочники.Организации.СоздатьЭлемент();
		ОрганизацияОбъект.УстановитьСсылкуНового(Организация);
		
		ОрганизацияОбъект.Наименование = СсылкаНаОбъект.Наименование;
		ОрганизацияОбъект.ГоловнаяОрганизация = Организация;
		ОрганизацияОбъект.НаименованиеПолное = СсылкаНаОбъект.НаименованиеПолное;
		ОрганизацияОбъект.НаименованиеСокращенное = СсылкаНаОбъект.Наименование;
		ОрганизацияОбъект.ЮрФизЛицо = Перечисления.ЮрФизЛицо.ЮрЛицо;
		ОрганизацияОбъект.ЮридическоеФизическоеЛицо = Перечисления.ЮридическоеФизическоеЛицо.ЮридическоеЛицо;
		
		ОрганизацияОбъект.Записать();
		
	КонецЕсли;

	Возврат Организация;
	
КонецФункции



Процедура СоздатьНовыеЭлементыПоТранзакциям() Экспорт

	Соединение = ПодключитьсяКбазе();
	Если Соединение = Неопределено Тогда 
		//Сообщить("Ошибка установки соединения.");
		Возврат;
	КонецЕсли;
	
	//// Аккаунты
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Т.AgreementScId КАК AgreementScId
		|ИЗ
		|	РегистрСведений.ТранзакцииESD КАК Т
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СоглашенияСКлиентами КАК Соглашения
		|		ПО Т.AgreementScId = Соглашения.Номер
		|ГДЕ
		|	Соглашения.Ссылка ЕСТЬ NULL";
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если СоздатьСоглашение(Соединение, ВыборкаДетальныеЗаписи.AgreementScId) Тогда
		Иначе
			ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка идентификации/создания объекта",
				УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецЕсли;
	КонецЦикла;
	//////

	
	//// Номенклатура
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	Т.NomenclatureScId КАК NomenclatureScId,
		|	Т.Manufacture КАК Manufacture
		|ИЗ
		|	РегистрСведений.ТранзакцииESD КАК Т
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
		|		ПО Т.NomenclatureScId = Номенклатура.Артикул
		|ГДЕ
		|	Номенклатура.Ссылка ЕСТЬ NULL";
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если СоздатьНоменклатуру(Соединение, ВыборкаДетальныеЗаписи.NomenclatureScId, ВыборкаДетальныеЗаписи.Manufacture) Тогда
		Иначе
			ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка идентификации/создания объекта",
				УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецЕсли;
	КонецЦикла;
	//////

	
	//// Комплектующие
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	С.SerialSetScId КАК SerialSetScId
		|ИЗ
		|	РегистрСведений.СерииESD КАК С
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Номенклатура КАК Номенклатура
		|		ПО С.SerialSetScId = Номенклатура.Артикул
		|ГДЕ
		|	НЕ С.SerialSetScId = ""123"" И
		|	Номенклатура.Ссылка ЕСТЬ NULL";
	
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ВыборкаДетальныеЗаписи.SerialSetScId = "123" Тогда
			Продолжить;
		КонецЕсли;
		Если СоздатьНоменклатуру(Соединение, ВыборкаДетальныеЗаписи.SerialSetScId) Тогда
		Иначе
			ЗаписьЖурналаРегистрации("Обработка транзакций ESD. Ошибка идентификации/создания объекта",
				УровеньЖурналаРегистрации.Ошибка,,, ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		КонецЕсли;
	КонецЦикла;
	//////
	
	
//////	//// Серии
//////	ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Игры");
//////	Запрос = Новый Запрос;
//////	Запрос.Текст = 
//////		"ВЫБРАТЬ РАЗЛИЧНЫЕ
//////		|	С.SerialId КАК SerialId
//////		|ИЗ
//////		|	РегистрСведений.СерииESD КАК С
////////		|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ РегистрСведений.ТранзакцииESD КАК Т
////////		|		ПО С.ServerTxId = Т.ServerTxId
////////		|			И (Т.Manufacture)
////////		|			И (Т.Date = &Date)
//////		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.СерииНоменклатуры КАК Серии
//////		|		ПО С.SerialId = Серии.Номер
//////		|ГДЕ
//////		|	Серии.Ссылка ЕСТЬ NULL";
//////	
////////	Запрос.УстановитьПараметр("Date", Дата);
//////	РезультатЗапроса = Запрос.Выполнить();
//////	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
//////	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
//////		СерияОбъект = Справочники.СерииНоменклатуры.СоздатьЭлемент();
//////		СерияОбъект.Номер = СокрЛП(ВыборкаДетальныеЗаписи.SerialId);
//////		СерияОбъект.ВидНоменклатуры = ВидНоменклатуры;
//////		СерияОбъект.Записать();
//////	КонецЦикла;
//////	//////
	
	
КонецПроцедуры

Функция СоздатьСоглашение(Соединение, Аккаунт)
	
	Попытка
		
		СсылкаНаОбъект = Соединение.Справочники.ДоговорыКонтрагентов.НайтиПоКоду(Аккаунт);
		
		Соглашение = Справочники.СоглашенияСКлиентами.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
		
		СоглашениеОбъект = Справочники.СоглашенияСКлиентами.СоздатьЭлемент();
		СоглашениеОбъект.УстановитьСсылкуНового(Соглашение);
		
		СоглашениеОбъект.Номер = Аккаунт;
		СоглашениеОбъект.Наименование = СсылкаНаОбъект.Наименование;
		СоглашениеОбъект.Валюта = Справочники.Валюты.НайтиПоКоду(СсылкаНаОбъект.ВалютаВзаиморасчетов.Code);
		СоглашениеОбъект.Организация = ПолучитьОрганизацию(Соединение, СсылкаНаОбъект.Организация);
		СоглашениеОбъект.Контрагент = ПолучитьКонтрагента(Соединение, СсылкаНаОбъект.Владелец);
		СоглашениеОбъект.Партнер = ПолучитьПартнера(Соединение, СсылкаНаОбъект.Владелец.ГоловнойКонтрагент);
		СоглашениеОбъект.ВидЦен = ПолучитьВидЦен(Соединение, СсылкаНаОбъект.ТипЦен);
		СоглашениеОбъект.ЦенаВключаетНДС = СоглашениеОбъект.ВидЦен.ЦенаВключаетНДС;
		СоглашениеОбъект.Склад = ПолучитьСклад(Соединение, СсылкаНаОбъект.СкладПоУмолчанию);
		СоглашениеОбъект.Согласован = Истина;
		//СоглашениеОбъект.Статус = ?(СсылкаНаОбъект.Активный, Перечисления.СтатусыСоглашенийСКлиентами.Действует, Перечисления.СтатусыСоглашенийСКлиентами.Закрыт);
		СоглашениеОбъект.Статус = Перечисления.СтатусыСоглашенийСКлиентами.Действует; // если статус "Не действует", не создается реализация (ошибка заполнения на основании соглашения)
		СоглашениеОбъект.ХозяйственнаяОперация = Перечисления.ХозяйственныеОперации.РеализацияКлиенту;
		СоглашениеОбъект.ПорядокОплаты = Перечисления.ПорядокОплатыПоСоглашениям.РасчетыВРубляхОплатаВРублях;
		СоглашениеОбъект.ПорядокРасчетов = Перечисления.ПорядокРасчетов.ПоДоговорамКонтрагентов;
		СоглашениеОбъект.ВалютаВзаиморасчетов = СоглашениеОбъект.Валюта;
		
		СоглашениеОбъект.Записать();
			
		Возврат Истина;
		
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Функция СоздатьНоменклатуру(Соединение, Артикул, ЭтоНабор = Ложь)
	
	Попытка
		
		СсылкаНаОбъект = Соединение.Справочники.Номенклатура.НайтиПоРеквизиту("Артикул", Артикул);
		
		Номенклатура = Справочники.Номенклатура.ПолучитьСсылку(Новый УникальныйИдентификатор(Соединение.XMLСтрока(СсылкаНаОбъект)));
		
		НоменклатураОбъект = Справочники.Номенклатура.СоздатьЭлемент();
		НоменклатураОбъект.УстановитьСсылкуНового(Номенклатура);
		
		ЗаполнитьЗначенияСвойств(НоменклатураОбъект, СсылкаНаОбъект, "Код,Наименование,Артикул,НаименованиеПолное");
		
		Запрос = Новый Запрос;
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	УпаковкиЕдиницыИзмерения.Ссылка КАК Ссылка
			|ИЗ
			|	Справочник.УпаковкиЕдиницыИзмерения КАК УпаковкиЕдиницыИзмерения
			|ГДЕ
			|	УпаковкиЕдиницыИзмерения.Код = &Код
			|	И УпаковкиЕдиницыИзмерения.Владелец = ЗНАЧЕНИЕ(Справочник.НаборыУпаковок.БазовыеЕдиницыИзмерения)";
		Запрос.УстановитьПараметр("Код", СсылкаНаОбъект.БазоваяЕдиницаИзмерения.Код);
		ВыборкаДетальныеЗаписи = Запрос.Выполнить().Выбрать();
		Если ВыборкаДетальныеЗаписи.Следующий() Тогда
			ЕдиницаИзмерения = ВыборкаДетальныеЗаписи.Ссылка;
		Иначе
			ЕдиницаИзмерения = Константы.ЕдиницаИзмеренияКоличестваШтук.Получить();
		КонецЕсли;
		НоменклатураОбъект.ЕдиницаИзмерения = ЕдиницаИзмерения;
		НоменклатураОбъект.ВариантОформленияПродажи = Перечисления.ВариантыОформленияПродажи.РеализацияТоваровУслуг;
		Если ЭтоНабор Тогда
			НоменклатураОбъект.ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Комплект кодов игр");
		Иначе
			НоменклатураОбъект.ВидНоменклатуры = Справочники.ВидыНоменклатуры.НайтиПоНаименованию("Игры");
		КонецЕсли;
		НоменклатураОбъект.ИспользованиеХарактеристик = Перечисления.ВариантыИспользованияХарактеристикНоменклатуры.НеИспользовать;
		НоменклатураОбъект.Качество = Перечисления.ГрадацииКачества.Новый;
		НоменклатураОбъект.СтавкаНДС = Перечисления.СтавкиНДС[Соединение.XMLСтрока(СсылкаНаОбъект.СтавкаНДС)];
		НоменклатураОбъект.ТипНоменклатуры = НоменклатураОбъект.ВидНоменклатуры.ТипНоменклатуры;
		НоменклатураОбъект.ЕдиницаДляОтчетов = ЕдиницаИзмерения;
		НоменклатураОбъект.КоэффициентЕдиницыДляОтчетов = 1;
		НоменклатураОбъект.ОсобенностьУчета = Перечисления.ОсобенностиУчетаНоменклатуры.БезОсобенностейУчета;
		
		НоменклатураОбъект.Записать();
			
		// создание штрихкода
		Запрос = Соединение.NewObject("Запрос");
		Запрос.Текст = 
		"ВЫБРАТЬ ПЕРВЫЕ 1
		|	ВЫРАЗИТЬ(Штрихкоды.Штрихкод КАК СТРОКА(200)) КАК Штрихкод
		|ИЗ
		|	РегистрСведений.Штрихкоды КАК Штрихкоды
		|ГДЕ
		|	Штрихкоды.Владелец = &Владелец		
		|";                                                                     
		Запрос.УстановитьПараметр("Владелец", СсылкаНаОбъект);   
		Выборка = Запрос.Выполнить().Выбрать();
		Если Выборка.Следующий() Тогда
			НаборЗаписей = РегистрыСведений.ШтрихкодыНоменклатуры.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.Штрихкод.Установить(Выборка.Штрихкод);
			Запись = НаборЗаписей.Добавить();
			Запись.Штрихкод = Выборка.Штрихкод;
			Запись.Номенклатура = Номенклатура;
			НаборЗаписей.Записать();
		КонецЕсли;	
		
		Возврат Истина;
		
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
КонецФункции

Процедура ЗагрузкаЦенПоТранзакциям() Экспорт
	
// делаем все из обработки "ЗагрузкаКорректировокВУПП"	
	
КонецПроцедуры


