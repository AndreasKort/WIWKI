#!/bin/bash

# Überprüfen, ob der Parameter übergeben wurde
if [ -z "$1" ]; then
    echo "Es wurde kein Suchbegriff angegeben."
    exit 1
fi

# Suchbegriff aus dem Parameter extrahieren
search_term=$1

# Wikipedia-Seite nach dem Suchbegriff durchsuchen
# Der curl-Befehl ruft die Wikipedia-API auf und durchsucht sie nach dem angegebenen Suchbegriff.
# Das Ergebnis wird in JSON-Format zurückgegeben und dann mit dem Werkzeug 'jq' geparst.
# Der Titel der ersten Suchergebnisseite wird in der Variablen $wiki_id gespeichert.
wiki_id=$(curl -s "https://en.wikipedia.org/w/api.php?action=query&format=json&list=search&srsearch=$search_term" | jq -r '.query.search[0].title')

# Überprüfen, ob eine Seite gefunden wurde
if [ -z "$wiki_id" ]; then
    echo "Es wurde keine Wikipedia-Seite für '$search_term' gefunden."
    echo "$(date): Keine Seite gefunden für '$search_term'" >> wikiscraper.log
    exit 1
fi

# Inhalt der Wikipedia-Seite abrufen
# Der curl-Befehl ruft erneut die Wikipedia-API auf, um den Inhalt der Seite abzurufen.
# Das Ergebnis wird wieder in JSON-Format zurückgegeben und mit 'jq' geparst.
# Der extrahierte Inhalt wird in der Variablen $wiki_content gespeichert.
wiki_content=$(curl -s "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&exintro&explaintext&redirects=1&titles=$wiki_id" | jq -r '.query.pages[].extract')

# Datei mit dem Namen des Suchbegriffs erstellen und den Inhalt speichern
# Der Name der Datei wird aus dem Suchbegriff abgeleitet, indem alle Buchstaben in Kleinbuchstaben umgewandelt werden.
# Der Inhalt der Wikipedia-Seite wird in die Datei geschrieben.
filename="${search_term,,}.wiki"
echo "$wiki_content" > "$filename"

# Erfolgsmeldung ausgeben und Log-Datei aktualisieren
echo "Die Wikipedia-Seite '$wiki_id' wurde erfolgreich in der Datei '$filename' gespeichert."
echo "$(date): Wikipedia-Seite '$wiki_id' in Datei '$filename' gespeichert." >> wikiscraper.log

