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
package actionScripts.ui.renderers
{
    import flash.display.Sprite;
    import flash.events.Event;
    
    import mx.binding.utils.ChangeWatcher;
    import mx.controls.treeClasses.TreeItemRenderer;
    import mx.core.UIComponent;
    import mx.core.mx_internal;
    import mx.events.ToolTipEvent;
    
    import spark.components.Label;
    
    import actionScripts.locator.IDEModel;
    import actionScripts.utils.UtilsCore;

	use namespace mx_internal;
	
	public class RepositoryTreeItemRenderer extends TreeItemRenderer
	{
		private var label2:Label;
		
		private var model:IDEModel;
		private var hitareaSprite:Sprite;
		private var isTooltipListenerAdded:Boolean;

		public function RepositoryTreeItemRenderer()
		{
			super();
			model = IDEModel.getInstance();
			ChangeWatcher.watch(model, 'activeEditor', onActiveEditorChange);
		}
		
		private function onActiveEditorChange(event:Event):void
		{
			invalidateDisplayList();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			if (!isTooltipListenerAdded)
			{
				addEventListener(ToolTipEvent.TOOL_TIP_CREATE, UtilsCore.createCustomToolTip, false, 0, true);
				addEventListener(ToolTipEvent.TOOL_TIP_SHOW, UtilsCore.positionTip, false, 0, true);
				isTooltipListenerAdded = true;
			}
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			hitareaSprite = new Sprite();
			hitArea = hitareaSprite;
			addChild(hitareaSprite);
		}
		
		override mx_internal function createLabel(childIndex:int):void
	    {
	        super.createLabel(childIndex);
	        label.visible = false;
	        
	        if (!label2)
			{	
				label2 = new Label();
				label2.mouseEnabled = false;
				label2.mouseChildren = false;
				label2.styleName = 'uiText';
				label2.setStyle('fontSize', 12);
				label2.maxDisplayedLines = 1;
				
				if (childIndex == -1) 
					addChild(label2);
				else 
					addChildAt(label2, childIndex);
			}
	    }
		
	    override mx_internal function removeLabel():void
	    {
	    	super.removeLabel();
	    	
	        if (label2 != null)
	        {
	            removeChild(label2);
	            label2 = null;
	        }
	    }
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
    	{
        	super.updateDisplayList(unscaledWidth, unscaledHeight);
        	
        	hitareaSprite.graphics.clear();
        	hitareaSprite.graphics.beginFill(0x0, 0);
        	hitareaSprite.graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
        	hitareaSprite.graphics.endFill();
        	hitArea = hitareaSprite;
        	
        	// Draw our own FTE label
        	label2.width = label.width;
        	label2.height = label.height;
			label2.x = label.x + 4;
        	label2.y = label.y + 6
        	
        	label2.text = label.text;
        	
        	if (label) label.visible = false;
		}
	}
}