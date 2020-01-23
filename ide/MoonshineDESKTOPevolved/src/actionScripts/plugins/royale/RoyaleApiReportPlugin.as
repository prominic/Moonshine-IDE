////////////////////////////////////////////////////////////////////////////////
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0 
// 
// Unless required by applicable law or agreed to in writing, software 
// distributed under the License is distributed on an "AS IS" BASIS, 
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and 
// limitations under the License
// 
// No warranty of merchantability or fitness of any kind. 
// Use this software at your own risk.
// 
////////////////////////////////////////////////////////////////////////////////
package actionScripts.plugins.royale
{
	import actionScripts.events.RoyaleApiReportEvent;
	import actionScripts.events.WorkerEvent;
	import actionScripts.factory.FileLocation;
	import actionScripts.interfaces.IWorkerSubscriber;
	import actionScripts.locator.IDEWorker;
	import actionScripts.plugin.IPlugin;
	import actionScripts.plugin.PluginBase;
	import actionScripts.valueObjects.ConstantsCoreVO;
	import actionScripts.valueObjects.RoyaleApiReportVO;
	import actionScripts.vo.NativeProcessQueueVO;

	import mx.utils.UIDUtil;

	public class RoyaleApiReportPlugin extends PluginBase implements IPlugin, IWorkerSubscriber
	{
		override public function get name():String			{ return "Apache Royale Api Report Plugin."; }
		override public function get author():String		{ return ConstantsCoreVO.MOONSHINE_IDE_LABEL +" Project Team"; }
		override public function get description():String	{ return "Apache Royale Api Report Plugin."; }

		private const API_REPORT_FILE_NAME:String = "royaleapireport.csv";

		private var worker:IDEWorker = IDEWorker.getInstance();
		private var queue:Vector.<Object> = new Vector.<Object>();
		private var subscribeIdToWorker:String;

		private var hasErrors:Boolean;

		public function RoyaleApiReportPlugin():void
		{
			super();
		}

		override public function activate():void
		{
			super.activate();

			subscribeIdToWorker = this.name + UIDUtil.createUID();

			dispatcher.addEventListener(RoyaleApiReportEvent.LAUNCH_REPORT_GENERATION, onLaunchReportGeneration);
		}

		override public function deactivate():void
		{
			super.deactivate();
		}

		private function onLaunchReportGeneration(event:RoyaleApiReportEvent):void
		{
			hasErrors = false;
			var reportConfig:RoyaleApiReportVO = event.reportConfiguration;
			var royaleMxmlc:String = reportConfig.royaleSdkPath + getMxmlcLocation();
			var flexConfig:String = reportConfig.flexSdkPath + getFlexConfigLocation();
			var apiReportName:String = reportConfig.reportOutputPath + model.fileCore.separator + API_REPORT_FILE_NAME;

			var libraryPath:String = "";
			for each (var library:FileLocation in reportConfig.libraries)
			{
				libraryPath += " -library-path+=".concat(library.fileBridge.nativePath, " ");
			}

			worker.subscribeAsIndividualComponent(subscribeIdToWorker, this);

			var fullCommand:String = royaleMxmlc.concat(" ",
					libraryPath,
					"-api-report=", apiReportName, " ",
					"-load-config=", flexConfig,  " ",
					reportConfig.mainAppFile);

			var reportCommand:NativeProcessQueueVO = new NativeProcessQueueVO(fullCommand, true);

			queue.push(reportCommand);

			worker.sendToWorker(WorkerEvent.RUN_LIST_OF_NATIVEPROCESS, {queue:queue, workingDirectory: reportConfig.workingDirectory}, subscribeIdToWorker);
		}

		private function getMxmlcLocation():String
		{
			return model.fileCore.separator + "bin" + model.fileCore.separator + "mxmlc";
		}

		public function getFlexConfigLocation():String
		{
			return model.fileCore.separator + "frameworks" + model.fileCore.separator + "flex-config.xml";
		}

		public function onWorkerValueIncoming(value:Object):void
		{
			switch (value.event)
			{
				case WorkerEvent.RUN_NATIVEPROCESS_OUTPUT:
					var match:Array = value.value.output.match(/Error/);
					if (match)
					{
						hasErrors = true;
						error(value.value.output);
					}
					else
					{
						print(value.value.output);
					}
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_PROCESS_TICK:
					if (queue.length != 0)
					{
						queue.shift();
					}
					break;
				case WorkerEvent.RUN_LIST_OF_NATIVEPROCESS_ENDED:
					if (hasErrors)
					{
						success("Generating report has ended with some errors.");
					}
					else
					{
						success("Generating report has ended.")
					}
					hasErrors = false;
					dispatcher.dispatchEvent(new RoyaleApiReportEvent(RoyaleApiReportEvent.REPORT_GENERATION_COMPLETED));
					break;
				case WorkerEvent.CONSOLE_MESSAGE_NATIVEPROCESS_OUTPUT:
					debug("%s", value.value);
					break;
			}
		}
	}
}