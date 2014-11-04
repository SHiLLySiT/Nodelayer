package models.state 
{
	public class NodeState implements IState
	{
		public var id:int;
		public var x:Number;
		public var y:Number;
		public var connectedNodes:Vector.<int>;
		public var isSelected:Boolean;
		
		public function NodeState() 
		{
			this.id = -1;
			this.x = 0;
			this.y = 0;
			this.connectedNodes = new Vector.<int>();
			this.isSelected = false;
		}
		
		public function hasConnection(id:int):Boolean
		{
			for each(var connection:int in connectedNodes)
			{
				if (connection == id)
				{
					return true;
				}
			}
			return false;
		}
		
	}

}