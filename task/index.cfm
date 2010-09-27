<cfset tasks = task.core.get_all_tasks() />
<h1>Tasks</h1>
<cfif isDefined('tasks') eq 0>
	<p>There are currently no tasks defined.</p>
<cfelse>
	<cfloop array="#tasks#" index="task">
		<p>
			<cfoutput>Name: #task.name#</cfoutput>
		</p>
	</cfloop>
</cfif>
<p><a href="add_task.cfm">Add Task</a></p>
