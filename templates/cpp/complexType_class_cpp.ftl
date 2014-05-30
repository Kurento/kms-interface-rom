${complexType.name}.cpp
/* Autogenerated with Kurento Idl */

<#list complexType.getChildren() as dependency>
<#if model.remoteClasses?seq_contains(dependency.type.type) ||
  model.complexTypes?seq_contains(dependency.type.type) ||
  model.events?seq_contains(dependency.type.type)>
#include "${dependency.type.name}.hpp"
</#if>
</#list>
#include "${complexType.name}.hpp"
#include <JsonSerializer.hpp>

namespace kurento {

<#if complexType.typeFormat == "REGISTER">
${complexType.name}::${complexType.name} (const Json::Value &value) {
  Json::Value aux;

  <#list complexType.properties as property>
  <#assign json_value_type = "">
  <#assign type_description = "">
  if (value.isMember ("${property.name}")) {
    <#if model.remoteClasses?seq_contains(property.type.type) >
    std::shared_ptr<MediaObject> obj;

    </#if>
    aux = value["${property.name}"];
    <#if property.type.isList()>
      <#assign json_value_type = "arrayValue">
      <#assign type_description = "array">
    <#elseif property.type.name = "String">
      <#assign json_value_type = "stringValue">
      <#assign type_description = "string">
    <#elseif property.type.name = "int">
      <#assign json_value_type = "intValue">
      <#assign type_description = "integer">
    <#elseif property.type.name = "boolean">
      <#assign json_value_type = "booleanValue">
      <#assign type_description = "boolean">
    <#elseif property.type.name = "double" || property.type.name = "float">
      <#assign json_value_type = "realValue">
      <#assign type_description = "double">
    <#elseif model.complexTypes?seq_contains(property.type.type) >
      <#assign json_value_type = "stringValue">
      <#assign type_description = "string">
    <#elseif model.remoteClasses?seq_contains(property.type.type) >
      <#assign json_value_type = "stringValue">
      <#assign type_description = "string">
    </#if>
    <#if json_value_type != "" && type_description != "">

    if (!aux.isConvertibleTo (Json::ValueType::${json_value_type})) {
      /* param '${property.name}' has invalid type value, raise exception */
      JsonRpc::CallException e (JsonRpc::ErrorCode::SERVER_ERROR_INIT,
                                "'${property.name}' parameter should be a ${type_description}");
      throw e;
    } else {
      JsonSerializer s(false);
      s.JsonValue = value;
      s.SerializeNVP(${property.name});
      <#if property.optional>
      _isSet${property.name?cap_first} = true;
      </#if>
    }
    <#else>
    // TODO, deserialize param type '${property.type}'
    </#if>
  }<#if !property.optional> else {
    /* Requiered property '${property.name}' not present, raise exception */
    JsonRpc::CallException e (JsonRpc::ErrorCode::SERVER_ERROR_INIT,
                              "'${property.name}' property is requiered");
    throw e;
  }
   <#else>

   </#if>

  </#list>
}
</#if>

} /* kurento */

void
Serialize(std::shared_ptr<kurento::${complexType.name}>& object, JsonSerializer& s)
{
<#if complexType.typeFormat == "REGISTER">
  if (!s.IsWriter && !object) {
    object.reset(new kurento::${complexType.name}());
  }

  if (object) {
  <#list complexType.properties as property>
    s.Serialize("${property.name}", object->${property.name});
  </#list>
  }

  if (!s.IsWriter) {
  <#list complexType.properties as property>
    <#if property.optional>

    if (s.JsonValue.isMember("${property.name}")) {
      object->_isSet${property.name?cap_first} = true;
    }
    </#if>
  </#list>

  }

<#else>
  if (s.IsWriter && object) {
    Json::Value v (object->getString() );

    s.JsonValue = v;
  } else {
    object.reset (new kurento::${complexType.name}(s.JsonValue.asString()));
  }
</#if>
}
