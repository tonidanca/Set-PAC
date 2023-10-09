1. Salvare lo script Set-PAC.ps1 in un path a piacere
2. Aprire le Schedulazioni di Windows ("Unità di pianificazione" o "Task Scheduler")
3. Importare la schedulazione dal file Set-PAC.xml (precedentemente salvato)
4. Modificare il path dello script da eseguite:
	a. Entrare nelle proprietà del task importato
	b. Andare nel tab Azioni
	c. Modificare l'operazione impostando il path corretto nel parametro -file
	d. Correggere la URL del file PAC e personalizzare la rete e il nome del processo da stoppare

NB:
I.  Le esecuzioni di script powershell devono essere abilitate
II. Se l'esecuzione del comando "pwsh" non funzionasse (solitamente perché non è stato installato Powershell v. 7 o superiore)
	cambiare con il comando "powershell" che esegue la powershell 5