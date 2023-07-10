<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.4-Białowieża">
  <fieldConfiguration>
    <field name="ng_co_id" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
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
    <field name="relative_to_terrain" configurationFlags="None">
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
    <field name="relative_to_water" configurationFlags="None">
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
    <field name="genericapplicationpropertyof" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field name="stationname" configurationFlags="None">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0" field="ng_co_id" name="Database ID (ng)"/>
    <alias index="1" field="id" name="Database ID"/>
    <alias index="2" field="gmlid" name="GML ID"/>
    <alias index="3" field="gmlid_codespace" name="GML ID Codespace"/>
    <alias index="4" field="name" name="Name"/>
    <alias index="5" field="name_codespace" name="Name Codespace"/>
    <alias index="6" field="description" name="Description"/>
    <alias index="7" field="creation_date" name="Creation Date"/>
    <alias index="8" field="termination_date" name="Termination Date"/>
    <alias index="9" field="relative_to_terrain" name="Relative to Terrain"/>
    <alias index="10" field="relative_to_water" name="Relative to Water"/>
    <alias index="11" field="last_modification_date" name="Last Modification Date"/>
    <alias index="12" field="updating_person" name="Updating Person"/>
    <alias index="13" field="reason_for_update" name="Reason for Update"/>
    <alias index="14" field="lineage" name="Lineage"/>
    <alias index="15" field="genericapplicationpropertyof" name="Generic Application Property"/>
    <alias index="16" field="stationname" name="Station Name"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint exp_strength="0" field="ng_co_id" constraints="3" unique_strength="1" notnull_strength="1"/>
    <constraint exp_strength="0" field="id" constraints="3" unique_strength="1" notnull_strength="1"/>
  </constraints>
  <constraintExpressions>
  </constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
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
      <attributeEditorField name="last_modification_date" showLabel="1" index="8"/>
      <attributeEditorField name="updating_person" showLabel="1" index="9"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="10"/>
      <attributeEditorField name="lineage" showLabel="1" index="11"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="WeatherStation Attributes" visibilityExpressionEnabled="0" showLabel="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="stationname" showLabel="1" index="12"/>
      <attributeEditorField name="genericapplicationpropertyof" showLabel="1" index="12"/>
    </attributeEditorContainer>
  </attributeEditorForm>
  <editable>
    <field name="creation_date" editable="0"/>
    <field name="gmlid" editable="0"/>
    <field name="gmlid_codespace" editable="0"/>
    <field name="id" editable="0"/>
    <field name="last_modification_date" editable="0"/>
    <field name="lineage" editable="0"/>
    <field name="ng_co_id" editable="0"/>
    <field name="termination_date" editable="0"/>
    <field name="updating_person" editable="0"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>0</layerGeometryType>
</qgis>
