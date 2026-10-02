
-- ABSCHLUSSPROJEKT DATENBANKEN UND SQL
-- Projekt A: Datenanalyse für einen Finanzdienstleister

-- Ziel:
-- 1. Merkmale für eine risikospezifische Kreditüberwachung identifizieren.
-- 2. Prüfen, ob Kreditvolumen und Pricing risikosensitiv erfolgen.

-- Datengrundlage:
-- credit_risk_dataset.csv
-- 32.581 Kreditdatensätze


USE credit_risk_db;


-- 1. DATENGRUNDLAGE UND DATENBEREINIGUNG

-- Vor der Analyse wurde der Datensatz auf fehlende und unplausible Werte geprüft.

-- Festgestellte Auffälligkeiten:
--  895 fehlende Werte bei person_emp_length
--  3.116 fehlende Werte bei loan_int_rate
--  2 unplausible Beschäftigungsdauern von 123 Jahren
--  5 Alterswerte über 100 Jahren

-- Fehlende bzw. eindeutig unplausible Werte wurden als NULL behandelt. Eine Ersetzung durch Mittelwert oder Median wurde bewusst nicht vorgenommen, um keine künstlichen Werte zu erzeugen.
-- Es wurden keine vollständigen Datensätze gelöscht, da die übrigen Merkmale weiterhin für die Analyse nutzbar waren.
-- Für die folgenden SQL-Analysen wird die bereinigte Tabelle "credit_risk_clean" verwendet.


-- Anzahl der Datensätze nach der Bereinigung kontrollieren 

SELECT
    COUNT(*) AS Anzahl_Datensaetze
FROM credit_risk_clean;


-- 2. ZIELVARIABLE UND GESAMTAUSFALLQUOTE

-- loan_status ist die zentrale Zielvariable der Analyse:
-- 0 = kein Kreditausfall
-- 1 = Kreditausfall

-- Gesamtausfallquote des Kreditbestands berechnen.
-- Da loan_status nur die Werte 0 und 1 enthält, zählt SUM(loan_status) automatisch alle Kreditausfälle.

SELECT
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    COUNT(*) - SUM(loan_status) AS Kein_Ausfall,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean;


-- 3. AUFGABE 1: RISIKOSPEZIFISCHE KREDITÜBERWACHUNG

-- 3.1 Ausfallrisiko nach Loan Grade

-- Es wird geprüft, ob sich die Ausfallquote zwischen den verschiedenen Loan Grades unterscheidet.

-- SUM(loan_status) zählt die Ausfälle, da loan_status nur die Werte 0 und 1 enthält.

SELECT
    loan_grade,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*), 2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade;

-- Ergebnis:
-- Die Ausfallquote steigt mit schlechter werdendem Loan Grade eutlich an. Besonders auffällig ist der Sprung von Grade C (20,73 %) auf Grade D (59,05 %).
-- Der Loan Grade ist daher ein wichtiges Merkmal für eine risikospezifische Kreditüberwachung.

-- Hinweis:
-- Grade G enthält nur 64 Kredite. Die sehr hohe Ausfallquote  sollte daher unter Berücksichtigung der kleinen Gruppengröße interpretiert werden.


-- 3.2 Ausfallrisiko nach Kreditanteil am Einkommen

-- Der Anteil der Kreditsumme am Einkommen wird in vier Gruppen eingeteilt, um zu prüfen, ob eine höhere Kreditbelastung mit höheren Ausfallquoten verbunden ist.

-- Die gewählten Grenzen dienen nur der Analyse des Datensatzes und stellen keine offiziellen Schwellenwerte dar.

SELECT
    CASE
        WHEN loan_percent_income < 0.10 THEN 'unter 10%'
        WHEN loan_percent_income < 0.20 THEN '10 bis unter 20%'
        WHEN loan_percent_income < 0.30 THEN '20 bis unter 30%'
        ELSE '30% und mehr'
    END AS Kreditanteil_Gruppe,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY Kreditanteil_Gruppe
ORDER BY Ausfallquote;

-- Ergebnis:
-- Die Ausfallquote steigt mit zunehmendem Kreditanteil am Einkommen.
-- Besonders auffällig ist die Gruppe ab 30 %: Hier liegt die Ausfallquote bei 65,46 %.
-- Der Kreditanteil am Einkommen ist daher ein weiteres wichtiges Merkmal für eine risikospezifische Überwachung.



-- 3.3 Ausfallrisiko nach Einkommensgruppe

-- Das Einkommen wird in fünf Gruppen eingeteilt. Ziel ist es zu prüfen, ob sich die Ausfallquote zwischen den Einkommensgruppen unterscheidet.

SELECT
    CASE
        WHEN person_income < 25000 THEN 'unter 25.000'
        WHEN person_income < 50000 THEN '25.000 bis unter 50.000'
        WHEN person_income < 75000 THEN '50.000 bis unter 75.000'
        WHEN person_income < 100000 THEN '75.000 bis unter 100.000'
        ELSE '100.000 und mehr'
    END AS Einkommensgruppe,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*), 2)AS Ausfallquote
FROM credit_risk_clean
GROUP BY Einkommensgruppe
ORDER BY Ausfallquote DESC;

-- Ergebnis:
-- Mit steigendem Einkommen sinkt die beobachtete Ausfallquote kontinuierlich.
-- Die niedrigste Einkommensgruppe weist mit 54,44 % die höchste Ausfallquote auf.Bei Einkommen ab 100.000 liegt sie nur noch bei 8,93 %.
-- Das Einkommen zeigt damit ebenfalls eine deutliche Risikodifferenzierung.



-- 3.4 Weitere Risikomerkmale

-- 3.4.1 Ausfallrisiko nach Wohnstatus

SELECT
    person_home_ownership,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY person_home_ownership
ORDER BY Ausfallquote DESC;

-- Ergebnis:
-- Mieter weisen eine deutlich höhere Ausfallquote auf als Kreditnehmer mit Wohneigentum oder Hypothek.
-- Die Kategorie OTHER ist wegen der geringen Fallzahl von nur 107 Krediten vorsichtig zu interpretieren.

-- 3.4.2 Ausfallrisiko nach Kreditzweck

SELECT
    loan_intent,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100.0 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY loan_intent
ORDER BY Ausfallquote DESC;

-- Ergebnis:
-- Auch der Kreditzweck zeigt Unterschiede in den beobachteten Ausfallquoten.
-- Die Unterschiede sind jedoch weniger stark ausgeprägt als bei Loan Grade, Kreditanteil und Einkommen.

-- 3.4.3 Ausfallrisiko nach historischem Kreditausfall

SELECT
    cb_person_default_on_file,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100.0 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY cb_person_default_on_file;

-- Ergebnis:
-- Kreditnehmer mit einem bereits dokumentierten historischen Kreditausfall weisen insgesamt eine höhere Ausfallquote auf.
-- Ob dieses Merkmal zusätzlich zum Loan Grade noch eine starke eigene Trennwirkung besitzt, wird später separat geprüft.




-- 3.5 Prüfung weiterer Merkmale mit geringerer Trennwirkung

-- Neben den bisher identifizierten Risikomerkmalen werden zusätzlich Alter, Beschäftigungsdauer und Länge der Kredithistorie betrachtet.
-- Hierzu werden die Durchschnittswerte von Kreditnehmern mit und ohne Kreditausfall verglichen.

-- 3.5.1 Durchschnittliches Alter nach Ausfallstatus

SELECT
    loan_status,
    ROUND(AVG(person_age), 2) AS Durchschnittsalter
FROM credit_risk_clean
GROUP BY loan_status;

-- 3.5.2 Durchschnittliche Beschäftigungsdauer nach Ausfallstatus

SELECT
    loan_status,
    ROUND(AVG(person_emp_length), 2) AS Durchschnittliche_Beschaeftigungsdauer
FROM credit_risk_clean
GROUP BY loan_status;

-- 3.5.3 Durchschnittliche Länge der Kredithistorie nach Ausfallstatus

SELECT
    loan_status,
    ROUND(AVG(cb_person_cred_hist_length), 2) AS Durchschnittliche_Kredithistorie
FROM credit_risk_clean
GROUP BY loan_status;

-- Ergebnis:
-- Beim Alter und bei der Länge der Kredithistorie bestehen nur geringe Unterschiede zwischen Krediten mit und ohne Ausfall.
-- Auch bei der Beschäftigungsdauer ist der Unterschied wesentlich kleiner als bei Loan Grade, Kreditanteil am Einkommen oder Einkommen.
-- Diese Merkmale werden daher nicht als zentrale Kriterienfür die spätere Überwachungslogik verwendet.



-- 3.6 Kombination aus Loan Grade und Kreditanteil am Einkommen

-- Bisher wurden Loan Grade und Kreditanteil am Einkommen getrennt betrachtet.
-- Nun wird geprüft, wie sich die Ausfallquote verändert, wenn beide Merkmale gemeinsam betrachtet werden.

SELECT
    loan_grade,
    CASE
        WHEN loan_percent_income < 0.10 THEN '1 - unter 10%'
        WHEN loan_percent_income < 0.20 THEN '2 - 10 bis unter 20%'
        WHEN loan_percent_income < 0.30 THEN '3 - 20 bis unter 30%'
        ELSE '4 - 30% und mehr'
    END AS Kreditanteil_Gruppe,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY
    loan_grade,
    Kreditanteil_Gruppe
ORDER BY
    loan_grade,
    Kreditanteil_Gruppe;
    
-- Ergebnis:
-- Der Kreditanteil am Einkommen liefert auch innerhalb der einzelnen Loan Grades zusätzliche Informationen.
-- Besonders Kredite mit einem Anteil von mindestens 30 % weisen innerhalb nahezu aller Grades deutlich höhere Ausfallquoten auf.
-- Loan Grade und Kreditanteil am Einkommen ergänzen sich daher als Kriterien für die Kreditüberwachung.



-- 3.7 Historischer Kreditausfall innerhalb der Loan Grades

-- Der historische Kreditausfall zeigte in der Gesamtbetrachtung eine höhere Ausfallquote.
-- Nun wird geprüft, ob dieser Unterschied auch innerhalb derselben Loan Grades bestehen bleibt.

SELECT
    loan_grade,
    cb_person_default_on_file,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY
    loan_grade,
    cb_person_default_on_file
ORDER BY
    loan_grade,
    cb_person_default_on_file;
    
-- Ergebnis:
-- In der Gesamtbetrachtung ist ein historischer Kreditausfall mit einer höheren Ausfallquote verbunden.
-- Innerhalb derselben Loan Grades sind die Unterschiede zwischen Y und N jedoch deutlich geringer und teilweiseogar gegenläufig.
-- Der historische Kreditausfall liefert daher gegenüber dem Loan Grade nur begrenzte zusätzliche Trennwirkung und wird nicht als eigenes Kriterium in die spätere Überwachungsregel aufgenommen.


-- 3.8 Vorschlag für eine risikospezifische Überwachungsregel

-- Auf Basis der vorherigen Analysen werden Kredite einer intensiveren Überwachung zugeordnet, wenn mindestens eines der folgenden Kriterien erfüllt ist:
-- - Loan Grade D bis G
-- - Kreditanteil am Einkommen von mindestens 30 %
-- - Einkommen unter 25.000

-- Alle übrigen Kredite werden der normalen Überwachung zugeordnet.

SELECT
    CASE
        WHEN loan_grade IN ('D', 'E', 'F', 'G') OR loan_percent_income >= 0.30 OR person_income < 25000 THEN 'Intensivere Überwachung'
        ELSE 'Normale Überwachung'
    END AS Ueberwachungsgruppe,
    COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
	ROUND(SUM(loan_status) * 100 / COUNT(*), 2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY Ueberwachungsgruppe
ORDER BY Ausfallquote DESC;

-- Ergebnis:
-- Die vorgeschlagene Überwachungsregel trennt zwei Gruppen mit deutlich unterschiedlichen Ausfallquoten.
-- In der Gruppe mit intensiverer Überwachung liegt die Ausfallquote bei 57,62 %, während sie bei der normalen Überwachung nur 6,88 % beträgt.
-- Die Regel zeigt damit, dass sich durch die Kombination ausgewählter Risikomerkmale eine risikoorientierte Überwachung des Kreditbestands ableiten lässt.

-- Hinweis:
-- Die Regel wurde ausschließlich aus den beobachteten Zusammenhängen dieses Datensatzes abgeleitet. Sie stellt kein validiertes Risikomodell dar.


-- 4. AUFGABE 2: KREDITVERGABE, KREDITVOLUMEN UND PRICING

-- 4.1 Durchschnittlicher Zinssatz nach Ausfallstatus

-- Zunächst wird geprüft, ob Kredite mit späterem Ausfall im Durchschnitt zu höheren Zinssätzen vergeben wurden.

SELECT
    loan_status,
    ROUND(AVG(loan_int_rate), 2) AS Durchschnittlicher_Zinssatz
FROM credit_risk_clean
GROUP BY loan_status;

-- Ergebnis:
-- Kredite mit Ausfall weisen im Durchschnitt einen höheren Zinssatz auf als Kredite ohne Ausfall.
-- Die Differenz beträgt rund 2,62 Prozentpunkte. Dies ist ein erster Hinweis darauf, dass das Pricing grundsätzlich auf unterschiedliche Risiken reagiert.


-- 4.2 Durchschnittlicher Zinssatz nach Loan Grade

-- Es wird geprüft, ob Kredite mit schlechterem Loan Grade im Durchschnitt zu höheren Zinssätzen vergeben werden.

SELECT
    loan_grade,
    ROUND(AVG(loan_int_rate), 2) AS Durchschnittlicher_Zinssatz
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade;

-- Ergebnis:
-- Der durchschnittliche Zinssatz steigt mit schlechter werdendem Loan Grade deutlich an.
-- Damit zeigt sich eine klare risikosensitive Preisgestaltung entlang des Loan Grades.



-- 4.3 Kreditvolumen und Kreditbelastung nach Loan Grade

-- Neben dem Pricing wird geprüft, wie hoch die durchschnittliche Kreditsumme und der durchschnittliche Kreditanteil am Einkommen innerhalb der einzelnen Loan Grades sind.

SELECT
    loan_grade,
    COUNT(*) AS Anzahl_Kredite,
    ROUND(AVG(loan_amnt),2) AS Durchschnittliche_Kreditsumme,
    ROUND(AVG(loan_percent_income) * 100,2) AS Durchschnittlicher_Kreditanteil
FROM credit_risk_clean
GROUP BY loan_grade
ORDER BY loan_grade;

-- Ergebnis:
-- Mit schlechter werdendem Loan Grade steigen tendenziell sowohl die durchschnittliche Kreditsumme als auch der Kreditanteil am Einkommen.
-- Besonders die Grades D bis G weisen höhere durchschnittliche Kreditvolumina und eine höhere relative Kreditbelastung auf.
-- Obwohl das Pricing über höhere Zinssätze auf das Risiko reagiert, zeigt sich bei der Kreditvergabe keine entsprechend starke Begrenzung des Kreditvolumens.



-- 4.4 Ausfallquote nach Kredithöhe

-- Es wird geprüft, ob sich die Ausfallquote mit der absoluten Höhe des vergebenen Kredits verändert.

SELECT
    CASE
        WHEN loan_amnt < 5000 THEN 'unter 5.000'
        WHEN loan_amnt < 10000 THEN '5.000 bis unter 10.000'
        WHEN loan_amnt < 15000 THEN '10.000 bis unter 15.000'
        WHEN loan_amnt < 20000 THEN '15.000 bis unter 20.000'
        ELSE '20.000 und mehr'
    END AS Kreditgroesse,
	COUNT(*) AS Anzahl_Kredite,
    SUM(loan_status) AS Ausfaelle,
    ROUND(SUM(loan_status) * 100.0 / COUNT(*), 2) AS Ausfallquote
FROM credit_risk_clean
GROUP BY Kreditgroesse
ORDER BY Kreditgroesse;

-- Ergebnis:
-- Mit steigender Kreditsumme nimmt die Ausfallquote tendenziell zu. Besonders ab einer Kreditsumme von 15.000 ist ein deutlicher Anstieg erkennbar.
-- Der Zusammenhang verläuft jedoch nicht durchgehend gleichmäßig und ist weniger eindeutig als beim Kreditanteil am Einkommen.


-- 4.5 Vergleich von niedrigerem und höherem Risiko

-- Für eine kompakte Managementauswertung werden die Loan Grades in zwei Gruppen zusammengefasst:
-- A bis C = niedrigeres Risiko D bis G = höheres Risiko
-- Verglichen werden Kreditsumme, Kreditanteil am Einkommen, Zinssatz und Ausfallquote.

SELECT
    CASE
        WHEN loan_grade IN ('A', 'B', 'C') THEN 'A-C'
        ELSE 'D-G'
    END AS Risikogruppe,
    COUNT(*) AS Anzahl_Kredite,
    ROUND(AVG(loan_amnt),2) AS Durchschnittliche_Kreditsumme,
    ROUND(AVG(loan_percent_income) * 100,2) AS Durchschnittlicher_Kreditanteil,
    ROUND(AVG(loan_int_rate),2) AS Durchschnittlicher_Zinssatz,
    ROUND(SUM(loan_status) * 100 / COUNT(*),2 ) AS Ausfallquote
FROM credit_risk_clean
GROUP BY Risikogruppe;


-- Prozentuale Differenz der durchschnittlichen Kreditsumme
-- zwischen den Gruppen D-G und A-C.



-- 4.6 Szenario: Keine Kreditvergabe an Loan Grades D bis G

-- Abschließend wird untersucht, welches Kreditvolumen betroffen gewesen wäre, wenn Kredite der Grades D bis G nicht vergeben worden wären.
-- Dabei wird zwischen später ausgefallenen und nicht ausgefallenen Krediten unterschieden.

SELECT
    COUNT(*) AS Anzahl_Kredite,	
    SUM(CASE WHEN loan_status = 1 THEN 1 ELSE 0 END) AS Anzahl_Ausfaelle,
    SUM(loan_amnt) AS Gesamtes_Kreditvolumen,
    SUM(CASE WHEN loan_status = 1 THEN loan_amnt ELSE 0 END) AS Kreditvolumen_mit_Ausfall,
    SUM(CASE WHEN loan_status = 0 THEN loan_amnt ELSE 0 END) AS Kreditvolumen_ohne_Ausfall
FROM credit_risk_clean
WHERE loan_grade IN ('D', 'E', 'F', 'G');

-- Ergebnis:
-- Bei einem vollständigen Ausschluss der Loan Grades D bis G wären 4.895 Kredite mit einem Gesamtvolumen von rund 56,44 Mio. nicht vergeben worden.
-- Davon entfielen rund 34,22 Mio. auf Kredite, die im vorliegenden Datensatz später ausgefallen sind.
-- Dieser Betrag darf jedoch nicht unmittelbar als tatsächliche Einsparung interpretiert werden. Der Datensatz enthält keine Informationen über Rückzahlungen, Sicherheiten, Recovery Rates oder entgangene Zinserträge.
-- Gleichzeitig wären auch 1.900 nicht ausgefallene Kredite mit einem Volumen von rund 22,21 Mio. nicht vergeben worden.






-- Gesamtergebnis:
-- Die Gruppe D-G weist mit 61,18 % eine deutlich höhere Ausfallquote auf als die Gruppe A-C mit 14,86 %.
-- Gleichzeitig ist die durchschnittliche Kreditsumme in der Gruppe D-G rund 24,69 % höher.
-- Das Pricing reagiert über deutlich höhere Zinssätze auf das höhere Risiko. Beim Kreditvolumen ist dagegen keine entsprechend restriktive Steuerung erkennbar.
-- Ob die Zinssätze wirtschaftlich ausreichend hoch sind, kann mit dem vorliegenden Datensatz nicht beurteilt werden, da beispielsweise Kosten, erwartete Verluste und interne Pricing-Vorgaben nicht enthalten sind.



-- 5. FAZIT


-- Aufgabe 1:
-- Die Analyse zeigt deutliche Unterschiede im Ausfallrisiko. Besonders relevant sind der Loan Grade, der Kreditanteil am Einkommen und das Einkommen.
-- Auf dieser Basis wurde eine einfache Überwachungslogik vorgeschlagen. Die Gruppe mit intensiverer Überwachung  weist eine Ausfallquote von 57,62 % auf, gegenüber 6,88 % bei der normalen Überwachung.
-- Die Regel stellt kein validiertes Risikomodell dar, sondern wurde ausschließlich aus den beobachteten Zusammenhängen des vorliegenden Datensatzes abgeleitet.


-- Aufgabe 2:
-- Das Pricing reagiert grundsätzlich auf das Kreditrisiko: Mit schlechter werdendem Loan Grade steigen die durchschnittlichen Zinssätze deutlich.
-- Gleichzeitig weist die Gruppe D-G eine Ausfallquote von 61,18 % auf und erhält im Durchschnitt rund 24,69 % höhere Kreditsummen als die Gruppe A-C.
-- Während das Pricing somit deutlich risikosensitiv erscheint, ist beim Kreditvolumen keine entsprechend restriktive Steuerung erkennbar.
-- Ob die Zinssätze wirtschaftlich ausreichend sind, kann mit den vorhandenen Daten nicht abschließend beurteilt werden.

