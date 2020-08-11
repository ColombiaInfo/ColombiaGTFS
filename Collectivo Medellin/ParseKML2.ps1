$path = "$PSScriptRoot\Paradas_de_Transporte_Público_Colectivo.csv"
$csv = Import-Csv -Delimiter ',' -Path $path -Encoding UTF8

# Sort the Get unique parts.
# sort the numbers by position
# Export to stop_times.txt
# export to stops.txt

$stops = @();


$UniqueStops = $csv | sort-object -Property ID_PARADERO -Unique

foreach ($row in $UniqueStops) {    
$stop = [PSCustomObject]@{
    stop_id = $row.ID_PARADERO
    stop_code = ''
    stop_name = $row.DIRECCION
    stop_desc = 'America/Bogota'
    stop_lat = $row.X
    stop_lon = $row.Y 
    zone_id = '' 
    stop_url = ''
    location_type = ''
    parent_station = ''
    stop_timezone = 'America/Bogota'
    wheelchair_boarding = '' 
    level_id = '' 
    platform_code = ''
    agency_email = ''
    }
    $stops += $stop
}

$stops | Export-Csv -Path "$PSScriptRoot\GTFS\stops.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''}


$UniqueRutas = $csv | Select CODIGO_RUTA | Sort-object -Property CODIGO_RUTA -Unique

Foreach ($UniqueRuta in $UniqueRutas) {
    $Rows = $csv.Where({ $_.CODIGO_RUTA -eq $UniqueRuta.CODIGO_RUTA })
    $RowsSorted = $Rows | Sort-object -Property NRO_PARADA
    $stop_times = @();
    $direction_id = '0'
    Foreach ($Row in $RowsSorted) {           
        if ( $Row.RECORRIDO -eq 'Origen-Destino') {           
            $direction_id = '0'           
        }
        else {            
            $direction_id = '1'            
        }

        $stop_time = [PSCustomObject]@{
            trip_id = $Row.CODIGO_RUTA + $direction_id
            arrival_time = ''
            departure_time = ''
            stop_id = $Row.ID_PARADERO
            stop_sequence = $Row.NRO_PARADA
            stop_headsign = '' 
            pickup_type = '' 
            drop_off_type = ''
            shape_dist_traveled = ''
            timepoint = ''
        }
        $stop_times += $stop_time
    }    
    $stop_times | Export-Csv -Append -Path "$PSScriptRoot\GTFS\stop_times.txt" -NoTypeInformation -Encoding UTF8 -Delimiter "," | % {$_ -replace '"',''}

}
