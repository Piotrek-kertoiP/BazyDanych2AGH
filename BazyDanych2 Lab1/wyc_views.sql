CREATE VIEW wycieczki_osoby
  AS
    SELECT
      w.ID_WYCIECZKI,
      w.NAZWA,
      w.KRAJ,
      w.DATA,
      o.IMIE,
      o.NAZWISKO,
      r.STATUS
    FROM WYCIECZKI w
      JOIN REZERWACJE r ON w.ID_WYCIECZKI = r.ID_WYCIECZKI
      JOIN OSOBY o ON r.ID_OSOBY = o.ID_OSOBY;


--a) wycieczki_osoby(kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
--b) wycieczki_osoby_potwierdzone (kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
--c) wycieczki_przyszle (kraj,data, nazwa_wycieczki, imie, nazwisko,status_rezerwacji)
--d) wycieczki_miejsca(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc) -- uwaga na ten widok
--e) dostępne_wyciezki(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)
--f) rezerwacje_do_ anulowania – lista niepotwierdzonych rezerwacji które powinne zostać
--anulowane, rezerwacje przygotowywane są do anulowania na tydzień przed wyjazdem)

create view osoby_potwierdzone
  as
    select
      w.kraj,
      w.data,
      w.nazwa,
      o.imie,
      o.nazwisko,
      r.status
    from WYCIECZKI w
      join REZERWACJE R on w.ID_WYCIECZKI = R.ID_WYCIECZKI
      join OSOBY O on R.ID_OSOBY = O.ID_OSOBY
    where r.STATUS like 'Z' or r.STATUS like 'P'


create view wycieczki_przyszle
  as
    SELECT
      w.kraj,
      w.data,
      w.nazwa,
      o.imie,
      o.nazwisko,
      r.status
    from WYCIECZKI w
      JOIN REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
      JOIN OSOBY o on r.ID_OSOBY = o.ID_OSOBY
    WHERE w.data > SYSDATE


CREATE VIEW wycieczki_miejsca-- uwaga na ten widok
  AS
    SELECT
      W.ID_WYCIECZKI,
      w.kraj,
      w.data,
      w.nazwa,
      w.liczba_miejsc,

      w.liczba_miejsc - (
                          select count(*)
                          from REZERWACJE r
                          WHERE r.ID_WYCIECZKI = w.ID_WYCIECZKI
                        ) as liczba_wolnych_miejsc
    FROM wycieczki w
      JOIN REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI


--CREATE VIEW dostępne_wyciezki(kraj,data, nazwa_wycieczki,liczba_miejsc, liczba_wolnych_miejsc)

create view dostepne_wycieczki
  as
    select
    w.kraj,
    w.data,
    w.nazwa,
    w.liczba_miejsc,

    w.liczba_miejsc - (
      select count(*)
      from REZERWACJE r
      WHERE r.ID_WYCIECZKI = w.ID_WYCIECZKI
    ) as liczba_wolnych_miejsc
  FROM wycieczki w
    JOIN REZERWACJE r on w.ID_WYCIECZKI = r.ID_WYCIECZKI
  where w.data > SYSDATE


--CREATE VIEW rezerwacje_do_ anulowania – lista niepotwierdzonych rezerwacji które powinne zostać
--anulowane, rezerwacje przygotowywane są do anulowania na tydzień przed wyjazdem)

create view rezerwacje_do_anulowania
  as
    select
      r.NR_REZERWACJI,
      r.ID_WYCIECZKI,
      r.ID_OSOBY,
      w.NAZWA as nazwa_wycieczki,
      w.KRAJ,
      w.DATA
    from REZERWACJE r
      join wycieczki w on r.ID_WYCIECZKI = w.ID_WYCIECZKI
    where r.status like 'N' and w.data + 7 > SYSDATE