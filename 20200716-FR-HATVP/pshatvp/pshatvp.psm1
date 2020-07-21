

Class Declaration {
    $Civilite #$Blanquer[1].general.declarant.civilite
    $Nom #$Blanquer[1].general.declarant.nom
    $Prenom #$Blanquer[1].general.declarant.prenom
    $DateNaissance #$Blanquer[1].general.declarant.dateNaissance
    $Mandat 
    $DebutMandat
    $TypeMandat
    $CodeListeOrgane
    hidden $Crue

    Declaration ([Object]$ItemXmlCrue){
        $this.Crue = $ItemXmlCrue  
        $This.Civilite = $This.Crue.general.declarant.civilite
        $This.Nom = $This.Crue.general.declarant.Nom
        $This.Prenom = $This.Crue.general.declarant.Prenom
        $This.DateNaissance = $This.Crue.general.declarant.dateNaissance
        $This.TypeMandat = $This.Crue.general.Mandat.Label
        $This.DebutMandat = $This.crue.general.dateDebutMandat
        $This.mandat = $this.Crue.general.organe.labelOrgane 
        $This.CodeListeOrgane = $this.Crue.general.organe.codeListeOrgane
    }

}

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

Function Download-MainFile {

    $Url =  "http://hatvp.fr/livraison/merge/declarations.xml"
    $ProgressPreferenceCurrent = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-RestMethod -Uri $Url -OutFile .\declarations.plop.xml
    $ProgressPreference = $ProgressPreferenceCurrent
}

Function Import-MainFile {
    Param(
        [System.Io.FileInfo]$Path = "$($psscriptRoot)\declarations.xml"
    )

    #Check if Zip file is present in module folder.
    #If present, unzip, and delete zip file.
    #Uncompress file https://ridicurious.com/2019/07/29/3-ways-to-unzip-compressed-files-using-powershell/?fbclid=IwAR0JdlMdeYCj8uqrR3jpbF-MsDt2TmodxQSTyuM_gJD4rqiAk985qTavo4s


    $Script:Declarations = [xml]::new()
    If($Path.Exists){
        $Script:Declarations.Load($Path.FullName)
        return $Script:Declarations
    }else{

        Write-Warning "File $($Path.fullName) not found"
    }
    

}

Function Get-MainFile {
    If(!($Script:Declarations)){
        Import-MainFile
    }Else{
        return $Script:Declarations
    }
    
}

Function Get-hatvpDeclaration {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Nom
    )
    $Name = [CultureInfo]::New("fr-FR",$false).TextInfo.ToTitleCase($Nom.ToLower())
    $DeclarationCrues = $Script:Declarations.selectnodes("//*[nom='$($Name)']/../..")
    Foreach($dc in $DeclarationCrues){
        [Declaration]::New($dc)
    }
    

}

$BaseUrl = 'https://www.hatvp.fr/livraison/dossiers/'