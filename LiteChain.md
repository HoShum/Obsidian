## 结构设计

### 1、UML图
```plantuml
interface Component {
	String getId();
	ComponentType getType();
	Object proceed(ChainContext context);
}

interface Node {
	void setComponent(Component component);
	Component getComponent();
	Node next();
}


enum ComponentType {
	Normal
	Switch
	Loop
}
```

