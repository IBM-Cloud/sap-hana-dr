variable "IBMCLOUD_API_KEY" {
	description	= "IBM Cloud API key. The IBM Cloud API Key can be created here: https://cloud.ibm.com/iam/apikeys"
	sensitive	= true
		validation {
			condition     = length(var.IBMCLOUD_API_KEY) > 43 #&& substr(var.IBMCLOUD_API_KEY, 14, 15) == "-"
			error_message = "The IBMCLOUD_API_KEY value must be a valid IBM Cloud API key."
		}
}

provider "ibm" {
    ibmcloud_api_key	= var.IBMCLOUD_API_KEY
    region				= var.REGION_DR
}

provider "ibm" {
	alias = "primary"
    ibmcloud_api_key	= var.IBMCLOUD_API_KEY
    region				= var.REGION
}