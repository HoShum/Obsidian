#Java/Tools
## 结构设计

### 1、UML图
```plantuml-svg
interface Component {
	String getId();
	ComponentType getType();
	Object proceed(ChainContext context);
}

Component --> ComponentType : Use

Class ChainContext {
	T get(Class<T> type);
	<T> void put(T cache);
}

Component --> ChainContext : Use

interface Node {
	void setComponent(Component component);
	Component getComponent();
	Node next();
}

class SingleNode 
class SwitchNode
class LoopNode

Node <|-- SingleNode
Node <|-- SwitchNode
Node <|-- LoopNode

Node o-- Component

Class Chain {
	List<Node> nodes;
}

Chain *-- Node

enum ComponentType {
	Normal
	Switch
	Loop
}
```

	