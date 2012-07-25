Ruote Workflow Test
===================

Playing around with the [Ruote](http://ruote.rubyforge.org/)
workflow engine. The example in this workflow does not really do
anything. I just created something to model a similar workflow that I am
using on a work related project.  

There is currently no GUI accept for RuoteKit running under 
http://localhost:3000/_ruote

Installation
------------

Application depends on mysql. sqlite will not work

`bundle install`

`rake db:migrate`

Run the specs:
`rake spec`

Workflow
--------

The workflow is defined in RequestItem::PDEF_PROCESS. A RequestItem does
not represent anything in particular. It is just something that has to
be run through this workflow in order to be processed. 

In order for a RequestItem to be processed it needs to go through the
following workflow:
1. Call Service1. This is a participant that represents a web service
   call to "service1"
2. Call Service2. This participant represents a web service call to
   "service2"
3. Go into a monitoring phase. This will monitoring something until the
   particpant decides that it is done
4. Do some post processing after monitoring.

At certain points in the workflow, the RequestItem's state will be
updated. A RequestItem should end up in the "completed" state when the
workflow is done. 

At any point that an error happens, the workflow will put the RequestItem into an
error state. The error will need to be reviewed by a RequestItemAdmin.
The admin can choose to reprocess the request item or cancel the
process. Reprocessing the item will start the workflow up again. 

The participant implementations are just placeholders and do not contain
any real logic besides responding to the engine. 

All particpants that represent service calls will be continually
retried until they respond or an error is thrown. I modelled it this way
to have automatic retries if the service is not up. 
