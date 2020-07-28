

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

Class Configuration {
    [DocumentDeclaration]$DocumentDeclaration
    [System.Io.DirectoryInfo]$DataFolder = "$PsScriptRoot\Data"
    [System.Io.fileInfo]$DeclarationsXmlFile = "$PsScriptRoot\Data\declarations.xml"
    [System.Io.fileInfo]$hatvpdataZipFile = "$PsScriptRoot\Data\hatvp_data.zip"
    [boolean]$DeclarationsXmlFilePresent

    Configuration(){
        
        $this.DeclarationsXmlFilepresent = $this.DeclarationsXmlFile.exists
        
    }

    [object[]]GetDeclarations(){
        return $this.DocumentDeclaration.GetDeclarations()
    }
    
    SetDocumentDeclaration([DocumentDeclaration]$Document){
        $this.DocumentDeclaration = $Document
    }

    [Boolean]IsDeclarationXMLFilePresent(){
        return $this.DeclarationsXmlFilepresent
    }

    [void]CheckDeclarationXMLFilePresent(){
        $this.DeclarationsXmlFile.Refresh()
        $this.DeclarationsXmlFilepresent = $this.DeclarationsXmlFile.Exists
    }

    [Void]ExpandHatvpData(){

        if(!($this.DeclarationsXmlFile.Exists) -and $this.hatvpdataZipFile.Exists){
            Expand-Archive -Path $this.hatvpdataZipFile.FullName -DestinationPath $this.datafolder.FullName
            $this.CheckDeclarationXMLFilePresent()
        }
    }

}

Class DocumentDeclaration {

    [System.Xml.XmlElement]$DeclarationsXML
    [System.Io.FileInfo]$Path = "$($psscriptRoot)\Data\declarations.xml"

    DocumentDeclaration(){
        
        If($this.Path.Exists){
            $xml = [xml]::new()
            $xml.Load($this.Path.FullName) # returns void
            $this.DeclarationsXML = $xml.declarations
        }else{

            Write-Warning "File $($this.Path.fullName) not found"
        }
    }
    
    [object[]]GetDeclarations(){
        
        return $this.Declarations
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

Function Invoke-MainFileDownload {

    $Url =  "http://hatvp.fr/livraison/merge/declarations.xml"
    $ProgressPreferenceCurrent = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'
    Invoke-RestMethod -Uri $Url -OutFile .\declarations.plop.xml
    $ProgressPreference = $ProgressPreferenceCurrent
}

Function Import-HatvpData {

    <#
    .SYNOPSIS
        Fonction privée permettant d'importer les donneés hatvp de base
    .DESCRIPTION
        Créer un object dans le scope 'script' de type DATA.
        Cette function ne doit être appeler que de maniere interne (lors du chargement du module par example).
    .EXAMPLE
        Import-hatvpdata
    .INPUTS
        N/A
    .OUTPUTS
        N/A
    .NOTES
        Auteur: Stéphane van Gulick
        version: 1.0
        History: 
            2020.28.07;van Gulick;Creation

    #>
    #Check if Zip file is present in module folder.
    #If present, unzip, and delete zip file.
    #Uncompress file https://ridicurious.com/2019/07/29/3-ways-to-unzip-compressed-files-using-powershell/?fbclid=IwAR0JdlMdeYCj8uqrR3jpbF-MsDt2TmodxQSTyuM_gJD4rqiAk985qTavo4s

    Return [Data]::New()
}

function Expand-DataDocument {
        #Function interne
    [CmdletBinding()]
    Param(
        [System.Io.fileinfo]$Source = "$psscriptRoot\Data\hatvp_data.zip",
        [System.Io.DirectoryInfo]$Destination = "$psscriptRoot\Data\"

    )
        Expand-Archive -Path $Source -DestinationPath $Destination
}

Function Get-HatvpConfiguration {
    $script:Configuration.DataFolder.Refresh()
    $script:Configuration.DeclarationsXmlFile.Refresh()
    $script:Configuration.hatvpdataZipFile.Refresh()
    $script:Configuration.CheckDeclarationXMLFilePresent() 
    return $script:Configuration
}


Function Get-hatvpDeclaration {
    Param(
        [Parameter(Mandatory=$True)]
        [String]$Nom
    )
    $Name = [CultureInfo]::New("fr-FR",$false).TextInfo.ToTitleCase($Nom.ToLower())
    $DeclarationCrues = $Script:Configuration.DocumentDeclaration.DeclarationsXML.selectnodes("//*[nom='$($Name)']/../..")
    Foreach($dc in $DeclarationCrues){
        [Declaration]::New($dc)
    }
    

}

$BaseUrl = 'https://www.hatvp.fr/livraison/dossiers/'

$Script:Configuration = [Configuration]::new()
$Script:Configuration.ExpandHatvpData()
$Script:Configuration.SetDocumentDeclaration([DocumentDeclaration]::New())

