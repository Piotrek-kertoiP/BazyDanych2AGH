
CREATE PACKAGE FUNKCJE AS
------------------------------------------------------------------------------------------------------------------------
  TYPE UCZESTNICY_RECORD IS RECORD (
    IMIE VARCHAR2(50),
    NAZWISKO VARCHAR2(50),
    STATUS_REZERWACJI CHAR(1));

  TYPE UCZESTNICY_TABLE IS TABLE OF UCZESTNICY_RECORD;
------------------------------------------------------------------------------------------------------------------------
  TYPE REZERWACJE_RECORD IS RECORD (
    NAZWA_WYCIECZKI VARCHAR2(50),
    KRAJ VARCHAR2(50),
    STATUS_REZERWACJI CHAR(1));

  TYPE REZERWACJE_TABLE IS TABLE OF REZERWACJE_RECORD;
------------------------------------------------------------------------------------------------------------------------
  TYPE WYCIECZKI_RECORD IS RECORD (
    ID_WYCIECZKI INT,
    NAZWA_WYCIECZKI VARCHAR2(50),
    KRAJ VARCHAR2(50),
    DATA_WYCIECZKI DATE,
    OPIS VARCHAR2(200),
    LICZBA_MIEJSC INT);

  TYPE WYCIECZKI_TABLE IS TABLE OF WYCIECZKI_RECORD;
------------------------------------------------------------------------------------------------------------------------
  TYPE WYCIECZKI_ARG IS RECORD(
    KRAJ_ VARCHAR(50),
    DATA_1 DATE,
    DATA_2 DATE);
------------------------------------------------------------------------------------------------------------------------
  FUNCTION UCZESTNICY_WYCIECZKI
    (ID_WYCIECZKI_ IN INT)
    RETURN UCZESTNICY_TABLE PIPELINED;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION REZERWACJE_OSOBY
    (ID_OSOBY IN INT)
    RETURN REZERWACJE_TABLE PIPELINED;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION PRZYSZLE_REZERWACJE_OSOBY
    (ID_OSOBY IN INT)
    RETURN REZERWACJE_TABLE PIPELINED;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION DOSTEPNE_WYCIECZKI
    (ARG IN WYCIECZKI_ARG)
    RETURN WYCIECZKI_TABLE PIPELINED;
------------------------------------------------------------------------------------------------------------------------
END;



CREATE PACKAGE BODY FUNKCJE AS
------------------------------------------------------------------------------------------------------------------------
  FUNCTION UCZESTNICY_WYCIECZKI
    (ID_WYCIECZKI_ IN INT)
    RETURN UCZESTNICY_TABLE PIPELINED
  AS
    check_id NUMBER(1);
    CURSOR uczestnicy IS
      SELECT
        w.IMIE,
        w.NAZWISKO,
        w.STATUS
      FROM WYCIECZKI_OSOBY w
        WHERE w.ID_WYCIECZKI = ID_WYCIECZKI_;
    BEGIN
      SELECT
        CASE
          WHEN EXISTS(SELECT * FROM WYCIECZKI w
                         WHERE w.ID_WYCIECZKI = ID_WYCIECZKI_)
           THEN 1
          ELSE 0
        END
      INTO check_id FROM DUAL;
      IF check_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak wycieczki o podanym id');
      END IF;
      FOR uc IN uczestnicy
      LOOP
        PIPE ROW ((uc));
      END LOOP;
    END;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION REZERWACJE_OSOBY
    (ID_ARG IN INT)
    RETURN REZERWACJE_TAB PIPELINED
  AS
    check_id NUMBER(1);
    CURSOR rezerwacje IS
      SELECT DISTINCT
        w.NAZWA,
        w.KRAJ,
        r.STATUS
      FROM WYCIECZKI_OSOBY w
        INNER JOIN REZERWACJE r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI AND r.ID_OSOBY = ID_ARG;
    BEGIN
      SELECT
        CASE
          WHEN EXISTS(SELECT * FROM OSOBY o
                        WHERE o.ID_OSOBY = ID_ARG)
           THEN 1
          ELSE 0
        END
      INTO check_id FROM DUAL;
      IF check_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak osoby o podanym id');
      END IF;
      FOR rez IN rezerwacje
      LOOP
        PIPE ROW ((rez));
      END LOOP;
    END;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION PRZYSZLE_REZERWACJE_OSOBY
    (ID_ARG IN INT)
    RETURN REZERWACJE_TAB PIPELINED
  AS
    check_id NUMBER(1);
    CURSOR rezerwacje IS
      SELECT DISTINCT
        w.NAZWA,
        w.KRAJ,
        w.STATUS
      FROM WYCIECZKI_OSOBY w
        INNER JOIN REZERWACJE r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI AND r.ID_OSOBY = ID_ARG AND w.DATA > SYSDATE;
    BEGIN
      SELECT
        CASE
          WHEN EXISTS(SELECT * FROM OSOBY o
                        WHERE o.ID_OSOBY = ID_ARG)
           THEN 1
          ELSE 0
        END
      INTO check_id FROM DUAL;
      IF check_id = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak osoby o podanym id');
      END IF;
      FOR rez IN rezerwacje
      LOOP
        PIPE ROW ((rez));
      END LOOP;
    END;
------------------------------------------------------------------------------------------------------------------------
  FUNCTION DOSTEPNE_WYCIECZKI
    (ARG IN WYCIECZKI_ARG)
    RETURN WYCIECZKI_TAB PIPELINED
  AS
    CURSOR wycieczki IS SELECT * FROM WYCIECZKI w
                          WHERE w.KRAJ = ARG.KRAJ_ AND w.DATA > ARG.DATA_1 AND w.DATA < ARG.DATA_2;
    BEGIN
      FOR wyc IN wycieczki
      LOOP
        PIPE ROW ((wyc));
      END LOOP;
    END;


END;


