# pw.APneuralnet

Progetto di supporto per il project-work di AP.

Il problema principale e riuscire, usando il pacchetto `{neuralnet}` a
sviluppare un sistema di gestione che permetta il tracciamento delle
learning curves e la gestione quindi delle ottimizzazioni che ne
derivano.

Attuali difficoltà: `{neuralnet}` sembra non riuscire a gestire una
esecuzione mirata delle epoche, in particolare anche se si possono
passare dei pesi iniziali, sembra impossibile fargli fare "una sola"
epoca in più, infatti parte dal presupposto di gestire lui le epoche e lo stopping e quindi se ha già raggiunto le performance che gli si mettono come soglia, l'epoca successiva non esegue nulla, se invece non la si raggiunge al primo run la funzione `neuralnet` restituisce un modello vuoto (pesi e modello) e quindi inutilizzabile.
