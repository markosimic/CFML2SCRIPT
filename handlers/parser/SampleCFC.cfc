<cfcomponent>

	<cffunction name="functionName" returntype="Array" access="private" output="false">
		<cfquery name="queryName" datasource="datasourceName" blockfactor="12">
			select * from 
			table
			where 
			param1 = <cfqueryparam cfsqltype="cf_sql_char" value="some_char_param1_value"> and
			param2 = <cfqueryparam list="true" cfsqltype="cf_sql_char" value="param2,1,2,3">
			order by col1 desc, col2
		</cfquery>
	</cffunction>


	<cffunction 
		name="functionName2" 
		returntype="void" hint="Some hint of functionName2">
		<cfquery 
			name="queryName2" 
			datasource="datasourceName" 
			blockfactor="12">
			select * 
			from table
			where 
				param1 = <cfqueryparam cfsqltype="cf_sql_char" value="some_char_value"> and
				param2 = <cfqueryparam list="true" cfsqltype="cf_sql_integer" value="1,2,3">
			order by col1 desc, col2
		</cfquery>
	</cffunction>

	<cffunction name="storedProcExample">
		<cfstoredproc procedure="SPNAME" datasource="DSN-NAME" returncode="yes" debug="yes">
			<cfprocresult name="data" resultset="1">
			<cfprocparam type="in" dbvarname="someid" cfsqltype="CF_SQL_INTEGER" value="#This.ID#">
			<cfprocparam type="in" dbvarname="somemoney" 	cfsqltype="cf_sql_decimal" value="#This.Tenant#">
			<cfprocparam type="inout" dbvarname="text"  cfsqltype="cf_sql_char" value="" variable="text">
			<cfprocparam type="out" dbvarname="status" cfsqltype="cf_sql_decimal" value="0" variable="status">
		</cfstoredproc>
	</cffunction>
	
</cfcomponent>