
$BaseUrl = 'https://www.hatvp.fr/livraison/dossiers/'
Import-Csv .\liste.csv -Delimiter ';'

$Fullurl = $BaseUrl + $open_data


#



#Function privee
Function Get-hatvpListe {
        Param(

            [ValidateSet('csv','json')]$format = 'csv',
            [System.IO.DirectoryInfo]$Path = $pwd
        )
    $Url =  "https://www.hatvp.fr/files/open-data/liste.csv"
    $ProgressPreferenceCurrent = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-RestMethod -Uri $Url -OutFile .\liste.$($Format)
    $ProgressPreference = $ProgressPreferenceCurrent
}

Function Get-MainFile {

    $Url =  "http://hatvp.fr/livraison/merge/declarations.xml"
    $ProgressPreferenceCurrent = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-RestMethod -Uri $Url -OutFile .\declarations.plop.xml
    $ProgressPreference = $ProgressPreferenceCurrent
}

Function Import-MainFile {
    Param(
        [System.Io.FileInfo]$Path = "$($pwd.Path)\declarations.xml"
    )

    $script:Declarations = [xml]::new()
    $script:Declarations.Load($Path.FullName)
    

}

#Alias Get-Thunes

Function Get-hatvpDeclarations {
    Param(
        $Name
    )

    REturn $Script:Declarations.selectnodes("//*[nom='$($Name)']/../..")



}




#Import xml very very longtemps > 40s