# Hush Engine Usage Manual

## Introduction
Hush is a game engine with 2 simple core ideals:
  - Data Oriented Design.
  - Performance for iteration speed.

The first one revolves around gameplay approaches and the second one is simply the target feel of our editor, asides from that, we aim to be as frictionless as we possibly can, no inheritance for logic, not enforcing a model for your games, etc.

This being said, Hush provide a fully fletched Entity Component System API that is the recommended approach for using the engine, what follows on this document is a very simple guide and tutorial on how to use Hush and prepare a few simple systems that can give you the idea of how one might program increasingly more complex scenarios.

## ECS
### Part 1. The E
If you're not familiar with ECS, don't worry, it's a really simple idea to grab, let's start with the "E" part of it, these are the entities, put simply, Hush needs a way to represent "things" in the world, this is what we call an entity, it's more of a container than anything, entities by themselves don't have any relevant data, they can be represented by a single 64-bit unsigned integer, but Hush also provides a utility Entity class that contains methods for ease of use.

```csharp
// These two operations are equivalent, they instantiate a new entity in the current scene

Entity myPlayer = scene.CreateEntity(); // Uses the container utility class

uint64 myPlayer = scene.CreateEntityRaw(); // Uses a raw ID

```

For many entities, you might want to make them distinct or unique so you can look them up later or make debugging easier, there are two ways of doing this in Hush:

- Keys 
    - A key is a string that gets associated with your entity, it becomes a sort of a unique name in a way that trying to create an entity with the same key will result in a lookup that returns the original entity instead of a new one. A key is internally represented as a part of the entity's descriptor.
- Names
    - This is an identifier mostly for display purposes on the editor, it can be repeated across multiple entities and it is internally represented as a component.

### Part 2. The C
As we said, entities by themselves are not really of much use, this is what we have **components** for; these are pieces of data that can be associated with entities, they can really be whatever you'd like, Hush doesn't enforce any particular hierarchy or model by default, so you can model your data as you please, the only requirement is that you use the `[HushComponent]` annotation so that the engine can find your components at runtime and give you some nice editor tooling.

```csharp
// Declaring our component
[HushComponent]
struct Weapon {
    int32 ammo;
    int32 magazineCapacity;
    float fireRate;
};

// Assigning it to an entity
Entity revolver = scene.CreateEntityWithKey("Revolver");
Weapon* weaponComp = player.AddComponent<Weapon>();
weaponComp.ammo = INITIAL_REVOLVER_AMMO;
weaponComp.fireRate = 1.5f;
weaponComp.magazineCapacity = INITIAL_REVOLVER_AMMO;

```
Components are the data we need to operate on, entities are the containers of said data, so now, what about systems?

### Part 3. The S

Systems are a bit more loose in definition than those other 2, technically any function that operates on a component instance is a system, but, traditionally speaking, systems refer to functions that query for a particular set of components to act on. In Hush, this is done through the Query class.


