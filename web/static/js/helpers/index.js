export function flatten(responseObject) {
  return Object
    .entries(responseObject)
    .map(([host, dataArray]) => dataArray)
    .reduce((acc, dataArray) => [...acc, ...dataArray], []);
}

export function uniqueTypes(types) {
  const typeStrings = types.map(type => `${ type.name }:${ type.module }`);

  return [...new Set(typeStrings)]
    .map(typeString => {
    [name, module] = typeString.split(':');

    return { name, module };
  });
}
