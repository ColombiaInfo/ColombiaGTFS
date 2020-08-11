[xml]$XmlDocument = Get-Content -Path "$PSScriptRoot\Rutas_de_Transporte_Público_Colectivo.kml" -Encoding UTF8

$Agencyies = $XmlDocument.kml.Document.Folder.Placemark.ExtendedData.SchemaData.SimpleData | WHERE-Object {$_.name -eq "EMPRESA"} 
$Agencies = @();
$AgencyArray = $Agencyies.'#text'.Trim() | Select-object -Unique
$AgencyArray.Length
$a = 0;
foreach ($AgencyRow in $AgencyArray) {
    $Agency = [PSCustomObject]@{
    agency_id = 'SITVA-' + $a
    agency_name = $AgencyRow
    agency_url = 'https://planner.colombiainfo.org'
    agency_timezone = 'America/Bogota'
    agency_lang = '3'
    agency_phone = '' 
    agency_fare_url = '' 
    agency_email = ''
    }
    $Agencies += $Agency
    $a = $a + 1;
}
$Agencies | Export-Csv -Append -Path "$PSScriptRoot\GTFS\agency.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''} 

foreach ($Placemark in $XmlDocument.kml.Document.Folder.Placemark) {  
    $shapes = @();
    $routes = @();
    $trips = @();  
    $SimpleData = $Placemark.ExtendedData.SchemaData.SimpleData 
    $Codigo = $SimpleData | WHERE-Object {$_.name -eq "CODIGO"} | Select-Object -Property '#text'
    $RECORRIDO = $SimpleData | WHERE-Object {$_.name -eq "RECORRIDO"} | Select-Object -Property '#text'
    $EMPRESA = $SimpleData | WHERE-Object {$_.name -eq "EMPRESA"} | Select-Object -Property '#text'
    $NOMBRE = $SimpleData | WHERE-Object {$_.name -eq "NOMBRE"} | Select-Object -Property '#text'
    $TIPO = $SimpleData | WHERE-Object {$_.name -eq "TIPO"} | Select-Object -Property '#text'
    $RouteNR = $Codigo.'#text'
    $headsign = $NOMBRE.'#text'.split("-")
    $direction_id = ''
    $headsigntext = ''    
    if ($RECORRIDO.'#text' -eq 'Origen-Destino') {
        $RouteNR = $RouteNR + '-0'
        $direction_id = '0'
        if ($NOMBRE.'#text' -notcontains '-') {
            $headsigntext = $NOMBRE.'#text'
        }
        else {
            $headsigntext = $headsign[1].Trim()
        }        
    }
    else {
        $RouteNR = $RouteNR + '-1'
        $direction_id = '1'
        if ($NOMBRE.'#text' -notcontains '-') {
            $headsigntext = $NOMBRE.'#text'
        }
        else {
            $headsigntext = $headsign[0].Trim()
        }
    }
    
    # Find Agency
    $Pos = [array]::indexof($AgencyArray,$EMPRESA.'#text'.Trim())


    $route = [PSCustomObject]@{
    route_id = $Codigo.'#text'
    agency_id = 'Sitva-' + $Pos
    route_short_name = $Codigo.'#text'
    route_long_name = $NOMBRE.'#text'
    route_desc = $TIPO.'#text'
    route_type = '3'
    route_url = '' 
    route_color = '' 
    route_text_color = ''
    route_sort_order = ''

    }

    $trip = [PSCustomObject]@{
        route_id = $Codigo.'#text'
        service_id = 'FULLWEEK'
        trip_id = $RouteNR
        trip_headsign = $headsigntext
        trip_short_name = ''
        direction_id = $direction_id
        block_id = '' 
        shape_id = $RouteNR
        wheelchair_accessible = '0'
        bikes_allowed = '2'
    }

    # $routes += $route
    # $trips += $trip

    If([string]::IsNullOrEmpty($Placemark.LineString.coordinates)){  
    }
    else {

        $ShapeArray = $Placemark.LineString.coordinates.split(" ")
        $i = 0;
        foreach ($ShapeRow in $ShapeArray) {
            $LatLng = $ShapeRow.split(",")

            $shape = [PSCustomObject]@{
                shape_id = $RouteNR
                shape_pt_lat = $LatLng[0]
                shape_pt_lon = $LatLng[1]
                shape_pt_sequence = $i
                shape_dist_traveled = ''
            }   
            $i = $i + 1;
            $shapes += $shape
       }
   }
    Write-Output $RouteNR
    $shapes | Export-Csv -Append -Path "$PSScriptRoot\GTFS\shapes.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''}
    $route | Export-Csv -Append -Path "$PSScriptRoot\GTFS\routes.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''} 
    $trip | Export-Csv -Append -Path "$PSScriptRoot\GTFS\trips.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''} 
}


