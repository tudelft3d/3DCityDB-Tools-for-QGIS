<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field name="id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="gmlid_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="name_codespace" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="description" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="creation_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option> 
        </config>
      </editWidget>
    </field>
    <field name="termination_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="last_modification_date" configurationFlags="None">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="updating_person" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="reason_for_update" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="lineage" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="cityobject_weatherdata_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="values_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="weatherdatatype" configurationFlags="None">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
      </editWidget>
    </field>
    <field name="weatherstation_parameter_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" name="Database ID" field="id"/>
    <alias index="1" name="GML ID" field="gmlid"/>
    <alias index="2" name="GML ID Codespace" field="gmlid_codespace"/>
    <alias index="3" name="Name" field="name"/>
    <alias index="4" name="Name Codespace" field="name_codespace"/>
    <alias index="5" name="Description" field="description"/>
    <alias index="6" name="Creation Date" field="creation_date"/>
    <alias index="7" name="Termination Date" field="termination_date"/>
    <alias index="10" name="Last Modification Date" field="last_modification_date"/>
    <alias index="11" name="Updating Person" field="updating_person"/>
    <alias index="12" name="Reason for Update" field="reason_for_update"/>
    <alias index="13" name="Lineage" field="lineage"/>
    <alias index="14" name="CityObject Weatherdata ID" field="cityobject_weatherdata_id"/>
    <alias index="15" name="Values ID" field="values_id"/>
    <alias index="16" name="Weatherdata Type" field="weatherdatatype"/>
    <alias index="18" name="Weatherstation Parameter ID" field="weatherstation_parameter_id"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint exp_strength="0" unique_strength="1" constraints="3" field="id" notnull_strength="1"/>
    <constraint exp_strength="0" unique_strength="0" constraints="4" field="cityobject_weatherdata_id" notnull_strength="0"/>
    <constraint exp_strength="0" unique_strength="0" constraints="4" field="values_id" notnull_strength="0"/>
    <constraint exp_strength="0" unique_strength="0" constraints="4" field="weatherdatatype" notnull_strength="0"/>
    <constraint exp_strength="0" unique_strength="0" constraints="4" field="weatherstation_parameter_id" notnull_strength="0"/>
  </constraints>
  <constraintExpressions>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode>></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
    <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="WeatherData Attributes" visibilityExpressionEnabled="0" showLabel="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="weatherstation_parameter_id" showLabel="1" index="12"/>
      <attributeEditorField name="cityobject_weatherdata_id" showLabel="1" index="12"/>
      <attributeEditorField name="weatherdatatype" showLabel="1" index=""/>
      <attributeEditorField name="values_id" showLabel="1" index=""/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field editable="0" name="cityobject_weatherdata_id"/>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="lineage"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="values_id"/>
    <field editable="0" name="weatherstation_parameter_id"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>0</layerGeometryType>
</qgis>
