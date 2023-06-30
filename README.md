## News
2018-12-07: Updated to julia v1.0, see commit eac09291 for last julia v0.6 version

[![pipeline status](https://gitlab.control.lth.se/processes/LabProcesses.jl/badges/master/pipeline.svg)](https://gitlab.control.lth.se/processes/LabProcesses.jl/commits/master)
[![coverage report](https://gitlab.control.lth.se/processes/LabProcesses.jl/badges/master/coverage.svg)](https://gitlab.control.lth.se/processes/LabProcesses.jl/commits/master)

# LabProcesses
Documentation available at [Documentation](http://processes.gitlab.control.lth.se/documentation/labprocesses/)


# Automatiskt genererad dokumentation
Det finns i skrivande stund två stycken mer eller mindre automatgenererade hemsidor med dokumentation, en sida till repot BallAndBeam.jl
    http://processes.gitlab.control.lth.se/documentation/ballandbeam/

och en sida till (detta) repot LabProcesses.jl
    http://processes.gitlab.control.lth.se/documentation/labprocesses

Mitt förslag är att alla som känner sig ansvariga för ett repo som är skapat med syfte att till slut överlämnas till framtida kollegor sätter upp liknande
dokumentation för detta repo.

## Generera dokumentation
Jag har byggt dokumentationen med [Documenter.jl](https://github.com/JuliaDocs/Documenter.jl). Detta verktyg accepterar en markdown-fil (docs/src/index.md)
med lite text man skrivit samt macron som indikerar att man vill infoga docstrings från funktioner och typer i sitt juliapaket.
Outputen är en html-sida med tillbehör som man ska se till att hosta på gitlab pages.

Exempel på hur detta går till finns i repona LabProcesses.jl och BallAndBeam.jl. Man kan helt sonika kopiera docs/-mappen från ett av dessa repon och
modifiera innehållet i alla filer så att det stämmer med ens nya repo.

## Hosting
För hosting finns repot
https://gitlab.control.lth.se/processes/documentation/
Det man behöver göra är att editera filen
https://gitlab.control.lth.se/processes/documentation/blob/master/.gitlab-ci.yml
och lägga till tre rader som

- Bygger dokumentationen i repot man vill dokumentera
- skapar en ny mapp med ett väl valt namn (myfoldername i exemplet nedan)
- flyttar den byggda dokumentationen till den mappen
- Det blir lätt att förstå hur man gör punkterna ovan när man kollar i filen .gitlab-ci.yml, bara kör mönstermatchning mot de repona som detta redan är gjort för.

När .gitlab-ci.yml uppdateras i master triggas en pipline. Om denna lyckas kommer dokumentationen finnas under

http://processes.gitlab.control.lth.se/documentation/myfoldername/
