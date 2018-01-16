Login-AzureRMAccount
Set-AzureRmContext –SubscriptionId bf8f23dc-8f88-417d-8b3b-da7cc4c74793


$RG1 = New-AzureRmResourceGroup -Name AzureTask2_1 -Location westeurope
#VNet1
$GWSubnet1 = New-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 192.168.200.0/28
New-AzureRmVirtualNetwork -ResourceGroupName $RG1.ResourceGroupName -Name Task2VNet1 -AddressPrefix 192.168.0.0/16 -Subnet $GWSubnet1 -Location westeurope
$vnet1 = Get-AzureRmVirtualNetwork -ResourceGroupName $RG1.ResourceGroupName -Name Task2VNet1
$subnet1 = Get-AzureRmVirtualNetworkSubnetConfig -Name $GWSubnet1.Name -VirtualNetwork $vnet1
$pip1 = New-AzureRmPublicIpAddress -Name Task2IP1 -ResourceGroupName $RG1.ResourceGroupName -Location westeurope -AllocationMethod Dynamic
$ipcinfig1 = New-AzureRmVirtualNetworkGatewayIpConfig -Name GWIPConfig1 -Subnet $subnet1 -PublicIpAddress $pip1
New-AzureRmVirtualNetworkGateway -Name Task2Gateway1 -ResourceGroupName $RG1.ResourceGroupName `
                                -Location westeurope -IpConfigurations $ipcinfig1 -GatewayType Vpn -VpnType RouteBased

$Gateway1 = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG1.ResourceGroupName -Name Task2Gateway1



$RG2 = New-AzureRmResourceGroup -Name AzureTask2_2 -Location northeurope
#VNet1
$GWSubnet2 = New-AzureRmVirtualNetworkSubnetConfig -Name GatewaySubnet -AddressPrefix 172.129.200.0/28
New-AzureRmVirtualNetwork -ResourceGroupName $RG2.ResourceGroupName -Name Task2VNet2 -AddressPrefix 172.129.0.0/16 -Subnet $GWSubnet2 -Location northeurope
$vnet2 = Get-AzureRmVirtualNetwork -ResourceGroupName $RG2.ResourceGroupName -Name Task2VNet2
$subnet2 = Get-AzureRmVirtualNetworkSubnetConfig -Name $GWSubnet2.Name -VirtualNetwork $vnet2
$pip2 = New-AzureRmPublicIpAddress -Name Task2IP2 -ResourceGroupName $RG2.ResourceGroupName -Location northeurope -AllocationMethod Dynamic
$ipcinfig2 = New-AzureRmVirtualNetworkGatewayIpConfig -Name GWIPConfig2 -Subnet $subnet2 -PublicIpAddress $pip2
New-AzureRmVirtualNetworkGateway -Name Task2Gateway2 -ResourceGroupName $RG2.ResourceGroupName `
                                -Location northeurope -IpConfigurations $ipcinfig2 -GatewayType Vpn -VpnType RouteBased

$Gateway2 = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $RG2.ResourceGroupName -Name Task2Gateway2



#Connect the VPN gateways
New-AzureRmVirtualNetworkGatewayConnection -Name conn1 -ResourceGroupName $RG1.ResourceGroupName `
-VirtualNetworkGateway1 $Gateway1 -VirtualNetworkGateway2 $Gateway2 -Location westeurope -ConnectionType Vnet2Vnet -SharedKey 'abc123'

New-AzureRmVirtualNetworkGatewayConnection -Name conn2 -ResourceGroupName $RG2.ResourceGroupName `
-VirtualNetworkGateway1 $Gateway2 -VirtualNetworkGateway2 $Gateway1 -Location northeurope -ConnectionType Vnet2Vnet -SharedKey 'abc123'


#Get-AzureRmVirtualNetworkGatewayConnection -Name conn1 -ResourceGroupName $RG1.ResourceGroupName -Debug
#Get-AzureRmVirtualNetworkGatewayConnection -Name conn2 -ResourceGroupName $RG2.ResourceGroupName -Debug


