#Tools #Java 
# Idea工具使用笔记
众所周知，Idea是日常开发中使用最频繁的工具，所谓工欲善其事必先利其器，因此掌握一些好用的技巧往往能让我们事半功倍
## 展示继承结构
对应Idea的窗口位置是：Navigate -> Type Hierarchy
对应的action则是：ActivateHierarchyToolWindow
## 分析类与类（接口）之间的关系
如果想分析两个类（接口）之间的关系，可以这样做，下面以分析Spring中`Advice`这个接口为例
1. 首先将Advice的一些子接口和实现类在diagram中展示出来
2. 右键 -> Content -> Add Class to Diagram，将`Advisor`这个接口添加进来
3. 右键 -> Content -> Show Dependencies
4. 由于Advisor中的一个方法是获取Advice，因此还需要展示方法，右键 -> Content -> Show Categories -> Methods

