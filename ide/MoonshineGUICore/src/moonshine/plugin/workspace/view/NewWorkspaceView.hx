package moonshine.plugin.workspace.view;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.controls.TextInput;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayoutData;
import feathers.layout.VerticalLayout;
import moonshine.plugin.workspace.events.WorkspaceEvent;
import moonshine.theme.MoonshineTheme;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;
import feathers.layout.AnchorLayoutData;
import feathers.controls.LayoutGroup;
import moonshine.ui.ResizableTitleWindow;
import openfl.events.Event;

import feathers.events.TriggerEvent;
class NewWorkspaceView extends ResizableTitleWindow {

	public function new() {
		super();
			
		this.title = "New Workspace";
		this.minHeight = 150.0;
		this.minWidth = 300.0;
		this.closeEnabled = true;
		this.resizeEnabled = true;
	}
	
	private var newWorkspaceButton:Button;
	private var workspaceNameTextInput:TextInput;
	
	private var _workspaces:ArrayCollection<String> = new ArrayCollection();
	
	@:flash.property
	public var workspaces(get, set):ArrayCollection<String>;

	private function get_workspaces():ArrayCollection<String> {
		return this._workspaces;
	}

	private function set_workspaces(value:ArrayCollection<String>):ArrayCollection<String> {
		if (this._workspaces == value) {
			return this._workspaces;
		}
		
		this._workspaces = value;
		this.setInvalid(InvalidationFlag.DATA);
		return this._workspaces;
	}
	
	override private function initialize():Void {
		var viewLayout = new VerticalLayout();
		viewLayout.horizontalAlign = JUSTIFY;
		viewLayout.paddingTop = 10.0;
		viewLayout.paddingRight = 10.0;
		viewLayout.paddingBottom = 10.0;
		viewLayout.paddingLeft = 10.0;
		viewLayout.gap = 10.0;
		this.layout = viewLayout;	
		
		this.workspaceNameTextInput = new TextInput();
		this.workspaceNameTextInput.prompt = "Workspace name";
		this.workspaceNameTextInput.addEventListener(Event.CHANGE, workspaceNameTextInput_changeHandler);
		this.addChild(this.workspaceNameTextInput);
		
		var footer = new LayoutGroup();
		footer.variant = MoonshineTheme.THEME_VARIANT_TITLE_WINDOW_CONTROL_BAR;
		this.newWorkspaceButton = new Button();
		this.newWorkspaceButton.variant = MoonshineTheme.THEME_VARIANT_DARK_BUTTON;
		this.newWorkspaceButton.text = "Create";
		this.newWorkspaceButton.addEventListener(TriggerEvent.TRIGGER, newWorkspaceButton_triggerHandler);
		footer.addChild(this.newWorkspaceButton);
		this.footer = footer;
		
		super.initialize();
	}
	
	private function workspaceNameTextInput_changeHandler(event:Event):Void {
			
	}	
	
	private function newWorkspaceButton_triggerHandler(event:Event):Void {
		var workspaceName = StringTools.trim(this.workspaceNameTextInput.text);
		
		if (workspaceName == null || workspaceName.length == 0) return;
		
		if (this._workspaces.contains(workspaceName)) return;
		
		var workspaceEvent = new WorkspaceEvent(WorkspaceEvent.NEW_WORKSPACE_WITH_LABEL, workspaceName);
		this.dispatchEvent(workspaceEvent);
		
		this.dispatchEvent(new Event(Event.CLOSE));
	}
	
	private function hasWorkspace(workspace:String, index:Int, arr:ArrayCollection<String>):Bool {
		return workspace == this.workspaceNameTextInput.text;
	}
}