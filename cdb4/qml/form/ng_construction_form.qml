<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="3.22.4-Białowieża" styleCategories="Fields|Forms">
  <fieldConfiguration>
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
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
    <field configurationFlags="None" name="termination_date">
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
    <field configurationFlags="None" name="last_modification_date">
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
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="opticalproperties_id">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="uvalue">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
    <field configurationFlags="None" name="uvalue_uom">
      <editWidget type="TextEdit">
      </editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias field="id" index="0" name="Database ID"/>
    <alias field="gmlid" index="1" name="GML ID"/>
    <alias field="gmlid_codespace" index="2" name="GML ID Codespace"/>
    <alias field="name" index="3" name="Name"/>
    <alias field="name_codespace" index="4" name="Name Codespace"/>
    <alias field="description" index="5" name="Description"/>
    <alias field="creation_date" index="6" name="Creation Date"/>
    <alias field="termination_date" index="7" name="Termination Date"/>
    <alias field="last_modification_date" index="10" name="Last Modification Date"/>
    <alias field="updating_person" index="11" name="Updating Person"/>
    <alias field="reason_for_update" index="12" name="Reason for Update"/>
    <alias field="opticalproperties_id" index="14" name="Optical Properties ID"/>
    <alias field="uvalue" index="15" name="U-value"/>
    <alias field="uvalue_uom" index="16" name="U-value UoM"/>
  </aliases>
  <defaults>
  </defaults>
  <constraints>
    <constraint notnull_strength="1" field="id" unique_strength="1" constraints="3" exp_strength="0"/>
    <constraint notnull_strength="0" field="uvalue" unique_strength="0" constraints="4" exp_strength="1"/>
    <constraint notnull_strength="0" field="uvalue_uom" unique_strength="0" constraints="4" exp_strength="1"/>
  </constraints>
  <constraintExpressions>
    <constraint exp="(&quot;uvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;uvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uvalue_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="uvalue"/>
    <constraint exp="(&quot;uvalue&quot; IS NOT NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uvalue_uom&quot; IS NOT NULL)&#xd;&#xa;OR&#xd;&#xa;(&quot;uvalue&quot; IS NULL&#xd;&#xa;AND&#xd;&#xa;&quot;uvalue_uom&quot; IS NULL)" desc="Both values must either be NULL or NOT NULL" field="uvalue_uom"/>
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
      <attributeEditorField showLabel="1" name="id" index="0"/>
      <attributeEditorField showLabel="1" name="description" index="5"/>
      <attributeEditorField showLabel="1" name="gmlid" index="1"/>
      <attributeEditorField showLabel="1" name="gmlid_codespace" index="2"/>
      <attributeEditorField showLabel="1" name="name" index="3"/>
      <attributeEditorField showLabel="1" name="name_codespace" index="4"/>
    </attributeEditorContainer>
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField showLabel="1" name="creation_date" index="6"/>
      <attributeEditorField showLabel="1" name="termination_date" index="7"/>
      <attributeEditorField showLabel="1" name="last_modification_date" index="8"/>
      <attributeEditorField showLabel="1" name="updating_person" index="9"/>
      <attributeEditorField showLabel="1" name="reason_for_update" index="10"/>
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer name="OpticalProperties" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
    </attributeEditorContainer>
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
    <attributeEditorContainer visibilityExpression="" groupBox="1" name="Feature-specific attributes" columnCount="2" showLabel="1" visibilityExpressionEnabled="0">
      <attributeEditorField showLabel="1" name="uvalue" index="12"/>
      <attributeEditorField showLabel="1" name="uvalue_uom" index="13"/>
      <attributeEditorField showLabel="1" name="opticalproperties_id" index="11"/>
    </attributeEditorContainer> 
  </attributeEditorForm>
  <editable>
    <field editable="0" name="creation_date"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="id"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="name"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="opticalproperties_id"/>
    <field editable="0" name="reason_for_update"/>
    <field editable="0" name="termination_date"/>
    <field editable="0" name="updating_person"/>
  </editable>
  <labelOnTop>
  </labelOnTop>
  <reuseLastValue>
  </reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
  <layerGeometryType>4</layerGeometryType>
</qgis>
