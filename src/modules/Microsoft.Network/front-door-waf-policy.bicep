/*
  author: Fernando Herrera <fherrera@intermexusa.com>
  type: Module
  description: This module creates a Front Door WAF firewall policy.
*/

// parameters
param location string = 'global'

param tags object = {}

@description('Resource name')
param name string

param sku object = {
  name: 'Classic_AzureFrontDoor'
}

@allowed([
  'Detection'
  'Prevention'
])
@description('Describes if it is in detection mode or prevention mode at policy level.')
param wafMode string = 'Prevention'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Describes if the policy is in enabled or disabled state. Defaults to Enabled if not specified.')
param wafState string = 'Enabled'

@description('List of managed rule sets for the policy.')
param managedRuleSets array = []

@description('Specifies whether to include the default rule set. Defaults to true.')
param includeDefaultRuleSet bool = true


// variables
var defaultRuleSet = [
  {
    ruleSetType: 'DefaultRuleSet'
    ruleSetVersion: '1.0'
  }
]
var combinedRuleSets = (includeDefaultRuleSet) ? concat(defaultRuleSet, managedRuleSets) : managedRuleSets


// resources
resource wafPolicy 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2020-11-01' = {
  name: name
  location: location
  tags: tags
  sku: sku
  properties: {
    policySettings: {
      mode: wafMode
      enabledState: wafState
    }
    managedRules: {
      managedRuleSets: combinedRuleSets
    }
  }
}

// outputs
output wafPolicyId string = wafPolicy.id
