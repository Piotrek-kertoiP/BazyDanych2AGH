CREATE OR REPLACE Procedure DODAJ_REZERWACJE
   ( id_wycieczki_ IN int,
    id_osoby_ in int)
IS
  check1 NUMBER(1); --1 GDY, TAKA WYCIECZKA ISTNIEJE ORAZ WYCIECZKA JESZCZE SIE NIE ODBYLA ORAZ SA JESZCZE WOLNE MIEJSCA
  check2 NUMBER(1); --1 GDY TAKA OSOBA ISTNIEJE
BEGIN
  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM WYCIECZKI_MIEJSCA w
                    WHERE w.ID_WYCIECZKI = id_wycieczki_ AND w.DATA > SYSDATE AND w.LICZBA_WOLNYCH_MIEJSC > 0)
        THEN 1
      ELSE 0
    END
  INTO check1 FROM DUAL;

  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM OSOBY o
                    WHERE o.ID_OSOBY = id_osoby_)
        THEN 1
      ELSE 0
    END
  INTO check2 FROM DUAL;

  IF check1 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Taka wycieczka nie istnieje, lub juz sie odbyla, lub nie ma juz wolnych miejsc');
  END IF;

  IF check2 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Osoba, ktora chcesz zapisac na wycieczke, nie istnieje');
  END IF;

  INSERT INTO rezerwacje(id_wycieczki, id_osoby, status)
        VALUES (id_wycieczki_, id_osoby_,'N');

  --DODANE W ZADANIU 6: (jakies problemy ze skladnia)

  INSERT INTO REZERWACJE_LOG(NR_REZERWACJI, DATA, STATUS )
        VALUES ( (SELECT r.NR_REZERWACJI FROM REZERWACJE r WHERE r.ID_WYCIECZKI = id_wycieczki and r.ID_OSOBY = id_osoby)), SYSDATE, status)

END;

SELECT r.NR_REZERWACJI FROM REZERWACJE r WHERE r.ID_WYCIECZKI = 5

------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE Procedure ZMIEN_LICZBE_MIEJSC
   ( id_wycieczki_ IN int,
    nowa_liczba_miejsc_ IN int)
IS
  check1 NUMBER(1); --czy wycieczka o podanym ID istnieje?
  check2 NUMBER(1); --czy zapisalo sie na wycieczke mniej osob, niz nasz nowy limit miejsc?
BEGIN
  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM WYCIECZKI w
                    WHERE w.ID_WYCIECZKI = id_wycieczki_ )
        THEN 1
      ELSE 0
    END
  INTO check1 FROM DUAL;

  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM WYCIECZKI_MIEJSCA w
                    WHERE w.ID_WYCIECZKI = id_wycieczki_
                    AND ( w. LICZBA_MIEJSC - w.LICZBA_WOLNYCH_MIEJSC < nowa_liczba_miejsc_ ))
                    --w. LICZBA_MIEJSC - w.LICZBA_WOLNYCH_MIEJSC = liczba osob juz zapisanych
        THEN 1
      ELSE 0
    END
  INTO check2 FROM DUAL;

  IF check1 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Wycieczka o podanym id nie istnieje');
  END IF;

  IF check2 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nie mozna zmienic na podana liczbe miejsc, bo za duzo osob sie juz zapisalo');
  END IF;

  UPDATE WYCIECZKI
    SET LICZBA_MIEJSC = nowa_liczba_miejsc_
    WHERE ID_WYCIECZKI = id_wycieczki_;
END;


------------------------------------------------------------------------------------------------------------------------

CREATE OR REPLACE Procedure ZMIEN_STATUS_REZERWACJI
   ( id_rezerwacji_ IN int,
    nowy_status_ IN CHAR)
IS
  check1 NUMBER(1); --czy istnieje podana rezerwacja?
  check2 NUMBER(1); --czy nowy status jest poprawny? (A,P,N lub Z)
  check3 NUMBER(1); --czy mozna zmienic na dany stan
  check4 NUMBER(1); --czy wycieczka sie juz odbyla? 1 jeszcze sie nie odbyla

  CURSOR status_oryginalny IS
      SELECT r.STATUS
      FROM REZERWACJE r
      WHERE NR_REZERWACJI = id_rezerwacji_ AND rownum = 1;

BEGIN
  SELECT
    CASE
      WHEN EXISTS(SELECT * FROM REZERWACJE r
                    WHERE r.NR_REZERWACJI = id_rezerwacji_ )
        THEN 1
      ELSE 0
    END
  INTO check1 FROM DUAL;

  IF nowy_status_ IN ('A', 'Z', 'N', 'P') THEN SELECT 1 INTO check2 FROM DUAL;
      ELSE SELECT 0 INTO check2 FROM DUAL;
  END IF;

  /*IF (status_oryginalny like 'N' AND nowy_status_ IN ('A', 'Z', 'P'))
    THEN SELECT 1 INTO check3 FROM DUAL;
      ELSIF ((status_oryginalny like 'P') AND (nowy_status_ IN ('A', 'Z')))
        THEN SELECT 1 INTO check3 FROM DUAL;
          ELSIF (status_oryginalny like 'Z' AND nowy_status_ IN ('A'))
            THEN SELECT 1 INTO check3 FROM DUAL;
              ELSE SELECT 0 INTO check3 FROM DUAL;
  END IF;*/

  /*SELECT 0 INTO check3 FROM DUAL;

  IF (status_oryginalny = 'N' AND nowy_status_ IN ('A', 'Z', 'P'))
  THEN SELECT 1 INTO check3 FROM DUAL;
  END IF;

  IF ((status_oryginalny = 'P') AND (nowy_status_ IN ('A', 'Z')))
  THEN SELECT 1 INTO check3 FROM DUAL;
  END IF;

  IF (status_oryginalny IN ('Z') AND nowy_status_ IN ('A'))
  THEN SELECT 1 INTO check3 FROM DUAL;
  END IF;*/

-- nie wiem czemu mialem problemy ze skladnia, mimo sporej ilosci kombinowania :(


  SELECT
      CASE
        WHEN EXISTS( SELECT * FROM REZERWACJE r
            JOIN WYCIECZKI w ON r.ID_WYCIECZKI = w.ID_WYCIECZKI AND w.DATA > SYSDATE AND r.NR_REZERWACJI = id_rezerwacji_)
          THEN 1
        ELSE 0
      END
    INTO check4 FROM DUAL;


  IF check1 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Rezerwacja o podanym id nie istnieje');
  END IF;

  IF check2 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Niepoprawny stan rezerwacji (podaj A, N, Z lub P');
  END IF;

  /*IF check3 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Nie mozna zmienic rezerwacji z aktualnego stanu na podany');
  END IF;*/

  IF check4 = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Wycieczka sie juz odbyla');
  END IF;

  UPDATE REZERWACJE
    SET STATUS = nowy_status_
    WHERE NR_REZERWACJI = id_rezerwacji_;

--dodane w zadaniu 6 - przechodzi bez warn'ow

  INSERT INTO REZERWACJE_LOG(nr_rezerwacji, data, status)
        VALUES (id_rezerwacji_, SYSDATE , nowy_status_);

END;
