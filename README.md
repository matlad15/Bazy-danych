# Bazy-danych

Obsługa bazodanowa serwera gier

Tworzymy bazę danych dla internetowego serwera gier. Serwer obsługuje kilkanaście różnych gier - dla przykładu: szachy, warcaby, go, backgamon, brydż, kierki, scrabble.  W Grach biorą udział Gracze; zależnie od Gry może ich być różna liczba. Gracz może korzystać z różnych gier. Dla każdej z gier, w których brał udział, jest prowadzona statystyka - historia rozgrywek wraz z zapisem ich przebiegu (należy poszukać systemów zapisu gier, który może być stosowany do wielu różnych gier, ew. dostosować go do potrzeb projektu), informacją kto brał w nich udział itd.
Rankingi

Jest również mierzona siła gry poszczególnych graczy. Jest to robione za pomocą jednego lub kilku rankingów wyliczanych na podstawie wyników rozegranych gier.  Powinna zaistnieć pewna uniwersalna formuła wyliczania rankingu, ale dla pewnych gier może zostać ona zastąpiona inną, bardziej dostosowaną do specyfiki gry.  Możliwe jest też (mile widziane) stworzenie dla jednej gry kilku alternatywnych rankingów.
Dobre rozwiązanie

Dobre rozwiązanie powinno być łatwo rozszerzalne - dodanie nowego typu gracza (np.  grający program komputerowy) czy nowej gry nie powinno stwarzać kłopotu.  Szczególnie należy zwrócić uwagę na możliwość dodania i/lub edycji formuł do wyliczania rankingów.

Powinny zostać przygotowane dane początkowe, które pozwolą testować poszczególne funkcjonalności w nietrywialny sposób.
