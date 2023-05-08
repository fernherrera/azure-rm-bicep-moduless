# Azure Templates README

## Getting Started

Requirements:

1. Git w/ Bash shell on Windows - (<https://git-scm.com/download>)
2. Azure CLI - (<https://docs.microsoft.com/en-us/cli/azure/install-azure-cli>)
3. Intermex Azure Resource Templates - (<https://dev.azure.com/intermexteam/_git/Tools>)

Download and install the latest version of Git for your platform.

**Note: When installing on Windows be sure to install the Bash shell option. The deployment scripts require Bash shell to run.**

Download and install the latest version of Azure CLI.

Clone the git repository or download the zip file of the Intermex Azure templates.

## Run the Azure CLI

You can now run the Azure CLI with the `az` command from Git Bash command line.  To sign in, run the `az login` command using the device code flow.

`az login --use-device-code`

Open a browser page at <https://aka.ms/devicelogin> and enter the authorization code displayed in your terminal.

Sign in with your account credentials in the browser.

To learn more about different authentication methods, see [Sign in with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli).

### Setting Azure Subscription

Upon a successful login you will see a list of subscriptions you have access to.  To select the subscription to deploy to use the `az account` command.

`az account set -s [subscription_id]`

## Deploying Resources with Templates

### Deploying All Resources

Navigate to the template folder for the application resources you wish to deploy.

`cd /c/Projects/Tools/az-imx-direct-resources/`

Execute the `deploy.sh` script and supply the parameter for the given environment you wish to deploy.  The available environments are under the `configs` folder.

`./deploy.sh -e dev`

### Deploying Specific Resources

To deploy only certain resources, for example deploying just application services you can specify which resources you want to deploy from the command line.

`./deploy.sh -e dev app-services`

You can also deploy multiple resources by providing a list of resources.

`./deploy.sh -e dev resource-group app-insights`

**Note: Resources will be deployed in the order that they appear in the command line.**

### Listing Available Resource Scripts

You can list the available resource templates with the `-l` flag.

`./deploy.sh -l`

## Testing Resource Template Deployment

You can use Azure CLI's `what-if` functionality to test the deployment scripts for syntax errors as well as what changes would be applied when deployed by using the `-t` flag.

`./deploy.sh -e dev -t`
