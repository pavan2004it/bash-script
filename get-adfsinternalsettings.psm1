function Get-AdfsInternalSettings()
{
    $settings = Get-AdfsProperties
    $settingsType = $settings.GetType()
    $propInfo = $settingsType.GetProperty("ServiceSettingsData", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic)
    $internalSettings = $propInfo.GetValue($settings, $null)

    $settingsData = Get-DataContractSerializedString -object $internalSettings

    $settingsData | Out-File ADFSConfigurationSettingsOutput.xml
} 

# Helper function - serializes any DataContract object to an XML string
function Get-DataContractSerializedString()
{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory = $true, HelpMessage="Any object serializable with the DataContractSerializer")]
        [ValidateNotNull()]
        $object
    )

    $serializer = New-Object System.Runtime.Serialization.DataContractSerializer($object.GetType())
    $serializedData = $null

    try
    {
        # No simple write to string option, so we have to write to a memory stream
        # then read back the bytes...
        $stream = New-Object System.IO.MemoryStream
        $writer = New-Object System.Xml.XmlTextWriter($stream,[System.Text.Encoding]::UTF8)

        $null = $serializer.WriteObject($writer, $object);
        $null = $writer.Flush();
                
        # Read back the text we wrote to the memory stream
        $reader = New-Object System.IO.StreamReader($stream,[System.Text.Encoding]::UTF8)
        $null = $stream.Seek(0, [System.IO.SeekOrigin]::Begin)
        $serializedData = $reader.ReadToEnd()
    }
    finally
    {
        if ($reader -ne $null)
        {
            try
            {
                $reader.Dispose()
            }
            catch [System.ObjectDisposedException] { }
        }

        if ($writer -ne $null)
        {
            try
            {
                $writer.Dispose()
            }
            catch [System.ObjectDisposedException] { }
        }

        if ($stream -ne $null)
        {
            try
            {
                $stream.Dispose()
            }
            catch [System.ObjectDisposedException] { }
        }
    }

    return $serializedData
}

Export-ModuleMember -Function Get-DataContractSerializedString
Export-ModuleMember -Function Get-AdfsInternalSettings