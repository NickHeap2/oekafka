set BOOTSTRAP_PROPATH=ablcontainer/ABLContainer.pl
set OPENEDGE_ENVIRONMENT=Development

set OpenEdge__databases__0__db=
set OpenEdge__databases__0__host=
set OpenEdge__databases__0__port=
set OpenEdge__databases__0__logical=
set OpenEdge__databases__0__username=
set OpenEdge__databases__0__password=

REM set Application__Setting1=true

set Serilog__MinimumLevel__Default=Information
REM set Serilog__WriteTo__0__Args__formatter=Serilog.Formatting.Compact.CompactJsonFormatter, Serilog.Formatting.Compact
REM set Serilog__WriteTo__1__Name=Elasticsearch
REM set Serilog__WriteTo__1__Args__nodeUris=http://elastic:9200
REM set Serilog__WriteTo__1__Args__indexFormat=test-index-{0:yyyy.MM.dd}
REM set Serilog__WriteTo__1__Args__emitEventFailure=ThrowException

C:\Progress\OpenEdge\bin\_progres.exe -param "BATCH" -b -p "ablcontainer/ABLContainer.pl<<ABLContainer/start.r>>" -assemblies assemblies
REM -clientlog D:\workspaces\oe-traceview\input.log -logentrytypes DB.Connects,4GLMessages:4,4GLTrace:4
