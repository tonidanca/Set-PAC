# Set-PAC

## English

1. Save the Set-PAC.ps1 script in a path of your choice
2. Open Windows Schedulers ("Scheduler" or "Task Scheduler")
3. Import the schedule from the Set-PAC.xml file (previously saved)
4. Change the path of the script to be executed:

* Enter the properties of the imported task
* Go to the Actions tab
* Modify the operation by setting the correct path in the -file parameter
* Correct the URL of the PAC file and customize the network and name of the process to stop

***NB:***

* Powershell script executions must be enabled
* If running the "pwsh" command doesn't work (usually because you don't have Powershell v. 7 or higher installed) change with the "powershell" command which runs powershell 5

-------

## Italian

1. Salvare lo script Set-PAC.ps1 in un path a piacere
2. Aprire le Schedulazioni di Windows ("Unità di pianificazione" o "Task Scheduler")
3. Importare la schedulazione dal file Set-PAC.xml (precedentemente salvato)
4. Modificare il path dello script da eseguite:

* Entrare nelle proprietà del task importato
* Andare nel tab Azioni
* Modificare l'operazione impostando il path corretto nel parametro -file
* Correggere la URL del file PAC e personalizzare la rete e il nome del processo da stoppare

***NB:***

* Le esecuzioni di script powershell devono essere abilitate
* Se l'esecuzione del comando "pwsh" non funzionasse (solitamente perché non è stato installato Powershell v. 7 o superiore) cambiare con il comando "powershell" che esegue la powershell 5
