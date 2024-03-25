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
	ChainContext context;
}

Chain *-- Node
Chain --> ChainContext : Contains

enum ComponentType {
	NORMAL
	SWITCH
	LOOP
}

interface ChainBuilder {
	Chain build(ChainELBuilder);
	Chain build(String xmlPath);
}

ChainBuilder --> Chain : Build

class Parser {
	List<Node> parse();
}

class ChainElParser extends Parser {
	List<Node> parse(ChainElBuilder builder);
}

class XmlParser extends Parser {
	List<Node> parse(String xmlPath);
}

ChainBuilder --> Parser : Use

class ChainELBuilder {
	begin(Component component);
	when(Component component);
	else(Component component);
	end();
}

ChainBuilder --> ChainELBuilder : Use

```
