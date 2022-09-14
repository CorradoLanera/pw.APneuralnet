# Preparativi -----------------------------------------------------


## dopo aver creato il progetto con supporto {renv} il nostroprogetto è
## isolato dal resto del pc, e quindi "senza alcun pacchetto".
## Installiamo (solo all'interno del progetto) i pacchetti che ci
## potrebbero servire

# Pacchetti di utilità per lo sviluppo
install.packages(
  c("usethis", "devtools", "testthat", "here")
)

# toolbox data analisi
install.packages("tidyverse")

# Gestore reti neurali prescelto
install.packages("neuralnet")



## Dopo aver installato tutti i pacchetti che ci servono (o ogni volta
## che ne installiamo di nuovi) ricordiamoci di salvarli "ufficialmente"
## nel progetto
renv::status()


## Per creare facilmente script di funzioni useremo la funzione
## usethis::use_r(<nomefunzione>), per creare poi la sua suite di
## test usiamola funzione usethis::use_test(<nomefunzione>).
## Gli script delle funzioni saranno salvati nella cartella R/ del
## progetto, i test nella cartella tests/testthat.
##
## Prima di tutto dobbiamo però attivare nel progetto l'ambiente di test
## e le sue funzionalità
usethis::use_testthat()




# Sviluppo --------------------------------------------------------



# dentro la cartella R creiamo tutte le funzioni (ausiliarie) che ci
# servono, in modo da sapere che sono li e tenere la "logica" del
# progetto (loscript di analisi) separata dal suo motore (le funzioni
# che usiamo e come sono costruite). Inoltre, guadagnamo di poterle
# testare (fondamentale! Anche per produrre e riprodurre problematiche
# che incontriamo e che risolviamo!).
#
# Visto che per il momento il nostro progetto è piuttosto semplice
# (lo stiamoiniziando quindi è semplice per definizione) partiamo
# costruendo un solo script per le funzioni che le contenga "tutte",
# questo almeno fino a quando non decideremo ceh sono "troppe" e
# opteremo per dividerle in script tematici.
usethis::use_r("functions")


## Inoltre creiamo subito il nostro file per i test di queste funzioni
## potremo eseguirli in un colpo solo, tutti, in automatico, in ogni
## momento in RStudio premendo CTRL/CMD + SHIFT + T
usethis::use_test("functions")


## > NOTA: per attivaretutte queste funzionalità, andiamo nelle
## impostazioni del progetto (Project Options...) di RStudio (dal menù
## "Tools", penultima voce), entriamo nella pagina "Build Tools" e
## dal menù a tendina selezioniamo la voce "package". Infine ci serve
## un file "DESCRIPTION" per formattato (per far credere a Red RStudio
## che stiamo creando un package). Per fare questo possiamo
## semplicemente eseguire la seguente istruzione, e ignorare del tutto
## il file "DESCRIPTION" che verrà creato (ovviamente possiamo aprirlo
## e completarlo a nostro piacimento, ma non è necessario, sopratutto,
## per farlo, serve saperlo fare e rispettare alcuni criteri.. il
## consiglio è fino a che non si sa bene quello che si fa, lasciarlo
## così e ignorarlo)
usethis::use_description(check_name = FALSE)



## attiviamo git e NON accettiamo di fare il primo commit,
## in quanto prima dobbiamo ignorare il contenuto di tutte le cartelle
## dei dati. POi faremo a mano il commit
usethis::use_git()

