# Service Principal
## Creating Applications
There are two ways to create an application:
- From [Azure Active Directory](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview)
- From [App Registration Tool](https://app.powerbi.com/embedsetup)

### Azure Active Directory
1) Open Link: [Azure Active Directory](https://portal.azure.com/#blade/Microsoft_AAD_IAM/ActiveDirectoryMenuBlade/Overview)
2) Manage -> App Registration </br>
![Location Of App Registration](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/Location%20Of%20App%20Registration.png)
3) New registration </br>
![App Registration](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/App%20Registration.png)
4) **Fill form:** </br>
       **Name: <your_app_name>**, </br>
       **Supported account type: <supported_acccount_type>** *(IIt depends on your intent. But mostly it will be: "Accounts in this organizational directory only (<name_of_your_tenant> only - Single tenant))"*, </br>
       **Redirect URI: <select_platform> + <url_adress>** *(This doesn't have to be filled. But it is recommended to fill it. It will be used to redirect the user after the user has logged in. For example  https://localhost:44300/redirect)*, </br>
![Registration Form in Azure](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/Form%20for%20App%20Registration.png)
5) Register
6) You will be redirected to a page about your application. There you can find **Application (Client) ID** and **Directory (Tenant) ID** in the Essentials section.
7) Switch to the **Certificates & secrets** tab and click on **New client secret**. </br>
![Certificates & Secrets](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/Client%20Secret%20Tab.png)
8) Set Description, Expiration date, and click on Add button. </br>
![Form to create Secret](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/Client%20Secret%20Creating%20Form.png)
9) !! Don't forget to copy Value (it will be your **Client Secret**) and Secret ID to safe place. *(Like to Azure Key Vault)* </br>
![Certificates & Secrets](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/src/img/My%20Super%20Secret%20Key.png)
10) Go to the **API permissions** tab and set all required **API permissions**. *(Required persmisions for selected call can be find in main [Readme.md](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/README.md) file of this repository)*
11) Did you make it? Wonderful!! Now you have your Service Principal ready to go! Have you already set up your Power BI Admin portal ([LINK](https://github.com/tirnovar/Power_BI_REST_API_PQ/blob/main/01_Prerequisites/Power%20BI%20Admin%20Set%20Up/Readme.md))?


### App Registration Tool
1) Open Link: [App Registration Tool](https://app.powerbi.com/embedsetup)
2) TBD
