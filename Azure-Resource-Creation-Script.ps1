#Log into your Azure account.

Connect-AzAccount

#Adjust the -SubscriptoinId property with your Subscription ID. Paste it within the single quotes.

Set-AzContext -SubscriptionId ''

#Set variables for Resource Groups, Data Factories and Location of resources. We will be using the <Your Initials>-<Project>-<Environment>-<Resource> naming scheme. 

#Since Azure Data Factory names must be unique across all of Azure, you might need to add a random number(s) to the end of your initials for it to be unique. This will not cause any issues going forward.

#Change the initial portion to your initials as I have used mine in the variables below. 

$ResourceGroupDEV = "rm-warehouse-dev-rg"
$ResourceGroupUAT = "rm-warehouse-uat-rg"
$ResourceGroupPROD = "rm-warehouse-prod-rg"
$DataFactoryDEV = 'rm-warehouse-dev-df'
$DataFactoryUAT = 'rm-warehouse-uat-df'
$DataFactoryPROD = 'rm-warehouse-prod-df'
$Location = 'canadacentral'

#Get the Resource Groups currently in your subscription.

$AvailableResourceGroups = Get-AzResourceGroup

#Create a list of Resource Groups to be created

$ResourceGroups = @($ResourceGroupDEV, $ResourceGroupUAT, $ResourceGroupPROD)

#For each Resource Group name in the list above, check to see if it is already present. If not, create the Resource Group. 

for ($i = 0; $i -lt $ResourceGroups.Count; $i++) {
    if ($AvailableResourceGroups.ResourceGroupName -eq $ResourceGroups[$i]) {

        Write-Host "Resource group $($ResourceGroups[$i]) already exists." -fore yellow

    }
    
    else {
        Write-Host "Creating resource group $($ResourceGroups[$i])." -fore cyan

        New-AzResourceGroup -Name $ResourceGroups[$i] -location $Location

        Write-Host "Resource group $($ResourceGroups[$i]) has been created." -fore green
    }
}

#Wait for 60 seconds to let the Resource Group creation process finalize. 

Write-Host "Waiting for 60 seconds for Resource Group creation." -fore magenta

Start-Sleep -Seconds 60

#Create a list of Data Factories to be created with the corresponding Resource Group Name based on environment.

$DataFactories = @()
$DataFactories += @{DataFactory = $DataFactoryDEV; ResourceGroup = $ResourceGroupDEV }
$DataFactories += @{DataFactory = $DataFactoryUAT; ResourceGroup = $ResourceGroupUAT }
$DataFactories += @{DataFactory = $DataFactoryPROD; ResourceGroup = $ResourceGroupPROD }

#For each Data Factory name in the list above, check to see if it is already present. If not, create the Data Factory. 

for ($i = 0; $i -lt $DataFactories.Count; $i++) {
    $AvailableDataFactories = Get-AzDataFactoryV2 -ResourceGroupName  $DataFactories[$i].ResourceGroup
    
    if ($AvailableDataFactories.DataFactoryName -eq $DataFactories[$i].DataFactory) {
    
        Write-Host "Data factory$($DataFactories[$i].DataFactory) already exists." -fore yellow
    }
    
    else {
        try {
            Write-Host "Creating data factory $($DataFactories[$i].DataFactory)." -fore cyan
    
            New-AzDataFactoryV2 -ResourceGroupName $DataFactories[$i].ResourceGroup -DataFactoryName $DataFactories[$i].DataFactory -Location $Location -ErrorAction Stop
            
        }
        catch {
            Write-Host "There was an error creating data factory $($DataFactories[$i].DataFactory)" -fore red

            throw "`rERROR: Data factory $($DataFactories[$i].DataFactory) could not be created." 
        }
        Write-Host "Data factory $($DataFactories[$i].DataFactory) has been created." -fore green
    }

}
